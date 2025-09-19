#include "flutter_window.h"

#include <appmodel.h>
#include <flutter/event_channel.h>
#include <flutter/method_result_functions.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <optional>

#include "flutter/generated_plugin_registrant.h"
#include "firebase/app_check.h"
#include "firebase/app_check/debug_provider.h"
#include "include/firebase/app/function_registry.h"
#include "include/firebase/app/reference_counted_future_impl.h"

void PlatformAppCheckProvider::GetToken(std::function<void(firebase::app_check::AppCheckToken, int, const std::string&)> completion_callback) {
  if (!FlutterWindow::instance || !FlutterWindow::instance->method_channel_app_check) {
    completion_callback({}, -2, "Instance cannot be found.");
    return;
  }

  std::string publisher = GetPublisher();
  auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
    {flutter::EncodableValue("publisher"), flutter::EncodableValue(publisher)},
  });
  auto result_handler = std::make_unique<flutter::MethodResultFunctions<>>(
    [completion_callback](const flutter::EncodableValue* value) {
      auto token = std::get<flutter::EncodableMap>(*value);
      completion_callback(
        firebase::app_check::AppCheckToken{
          std::get<std::string>(token["token"]),
          std::get<std::int32_t>(token["ttl"])
        },
        0,
        ""
      );
    },
    [completion_callback](const std::string& error_code, const std::string& error_message, const void* error_details) {
      completion_callback({}, -1, error_message);
    },
    [completion_callback]() {
      completion_callback({}, -3, "Method not implemented.");
    }
  );

  FlutterWindow::instance->method_channel_app_check->InvokeMethod("appCheck.requestToken", std::move(arguments), std::move(result_handler));
}

std::string PlatformAppCheckProvider::GetPublisher() {
  UINT32 length = 0;
  if (GetCurrentPackageId(&length, nullptr) == ERROR_INSUFFICIENT_BUFFER) {
    std::vector<BYTE> buffer(length);
    const auto packageId = reinterpret_cast<PACKAGE_ID*>(buffer.data());
    if (GetCurrentPackageId(&length, reinterpret_cast<BYTE*>(packageId)) == ERROR_SUCCESS && packageId->publisher != nullptr) {
      const std::wstring publisher(packageId->publisher);
      if (publisher.empty()) {
        return "";
      }

      const auto sizeNeeded = WideCharToMultiByte(CP_UTF8, 0, &publisher.at(0), static_cast<int>(publisher.size()), nullptr, 0, nullptr, nullptr);
      if (sizeNeeded <= 0) {
        throw std::runtime_error("WideCharToMultiByte() failed: " + std::to_string(sizeNeeded));
      }

      std::string result(sizeNeeded, 0);
      WideCharToMultiByte(CP_UTF8, 0, &publisher.at(0), static_cast<int>(publisher.size()), &result.at(0), sizeNeeded, nullptr, nullptr);
      return result;
    }
  }

  return "";
}

PlatformAppCheckProviderFactory* PlatformAppCheckProviderFactory::GetInstance() {
  static PlatformAppCheckProviderFactory app_check_provider_factory;
  return &app_check_provider_factory;
}

firebase::app_check::AppCheckProvider* PlatformAppCheckProviderFactory::CreateProvider(firebase::App* app) {
  // Create and return a PlatformAppCheckProvider object.
  return new PlatformAppCheckProvider();
}

FlutterWindow* FlutterWindow::GetInstance(const flutter::DartProject& project) {
  if (!instance) {
    instance = new FlutterWindow(project);
  }
  return instance;
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
  : project_(project) {
  future_manager().AllocFutureApi(this, kFlutterWindowFnCount);
}

FlutterWindow::~FlutterWindow() {
  future_manager().ReleaseFutureApi(this);
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
    frame.right - frame.left, frame.bottom - frame.top, project_
  );
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  method_channel_auth = std::make_unique<flutter::MethodChannel<>>(flutter_controller_->engine()->messenger(), "app.openauthenticator.auth", &flutter::StandardMethodCodec::GetInstance());
  method_channel_auth->SetMethodCallHandler([this](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
    if (call.method_name() == "auth.install" || call.method_name() == "auth.userChanged") {
      const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
      auto userIdValue = arguments->find(flutter::EncodableValue("userUid"));
      if (userIdValue != arguments->end()) {
        user_uid = std::get<std::string>(userIdValue->second);
      } else {
        user_uid = std::optional<std::string>();
      }
      if (call.method_name() == "auth.install") {
        const std::string appName = std::get<std::string>(arguments->find(flutter::EncodableValue("appName"))->second);
        firebase::App* app = firebase::App::GetInstance(appName.c_str());
        firebase::internal::FunctionRegistry* function_registry = app->function_registry();
        function_registry->RegisterFunction(::firebase::internal::FnAuthAddAuthStateListener, AddListener);
        function_registry->RegisterFunction(::firebase::internal::FnAuthRemoveAuthStateListener, RemoveListener);
        function_registry->RegisterFunction(::firebase::internal::FnAuthGetTokenAsync, GetCurrentUserIdToken);
        function_registry->RegisterFunction(::firebase::internal::FnAuthGetCurrentUserUid, GetCurrentUserUid);
        result->Success(true);
      } else {
        for (const Entry& entry : callbacks) {
          entry.first(entry.second);
        }
        result->Success(true);
      }
    } else {
      result->NotImplemented();
    }
  });

  method_channel_app_check = std::make_unique<flutter::MethodChannel<>>(flutter_controller_->engine()->messenger(), "app.openauthenticator.appcheck", &flutter::StandardMethodCodec::GetInstance());
  method_channel_app_check->SetMethodCallHandler([this](const flutter::MethodCall<>& call, std::unique_ptr<flutter::MethodResult<>> result) {
    if (call.method_name() == "appCheck.activate") {
      const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
      auto debugTokenValue = arguments->find(flutter::EncodableValue("debugToken"));
      if (debugTokenValue != arguments->end()) {
        std::string debugToken = std::get<std::string>(debugTokenValue->second);
        firebase::app_check::DebugAppCheckProviderFactory::GetInstance()
          ->SetDebugToken(debugToken);
        firebase::app_check::AppCheck::SetAppCheckProviderFactory(firebase::app_check::DebugAppCheckProviderFactory::GetInstance());
      } else {
        firebase::app_check::AppCheck::SetAppCheckProviderFactory(PlatformAppCheckProviderFactory::GetInstance());
      }
      result->Success(true);
    } else {
      result->NotImplemented();
    }
  });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (method_channel_auth) {
    method_channel_auth->SetMethodCallHandler(nullptr);
    method_channel_auth = nullptr;
  }
  if (method_channel_app_check) {
    method_channel_app_check->SetMethodCallHandler(nullptr);
    method_channel_app_check = nullptr;
  }
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message, WPARAM const wparam, LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result = flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam, lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

bool FlutterWindow::AddListener(firebase::App* app, void* callback, void* context) {
  if (!instance) {
    return false;
  }
  auto typed_callback = reinterpret_cast<FunctionRegistryCallback>(callback);
  instance->callbacks.emplace_back(typed_callback, context);
  return true;
}

bool FlutterWindow::RemoveListener(firebase::App* app, void* callback, void* context) {
  if (!instance) {
    return false;
  }
  auto typed_callback = reinterpret_cast<FunctionRegistryCallback>(callback);
  Entry entry = {typed_callback, context};

  auto iterator = std::find(instance->callbacks.begin(), instance->callbacks.end(), entry);
  if (iterator != instance->callbacks.end()) {
    instance->callbacks.erase(iterator);
  }
  return true;
}

bool FlutterWindow::GetCurrentUserIdToken(firebase::App* app, void* force_refresh, void* out) {
  firebase::Future<std::string>* out_future = static_cast<firebase::Future<std::string>*>(out);
  if (out_future) {
    *out_future = firebase::Future<std::string>();
  }

  bool* in_force_refresh = static_cast<bool*>(force_refresh);

  if (!instance || !instance->method_channel_auth) {
    return false;
  }

  assert(force_refresh);

  auto handle = instance->future()->SafeAlloc<std::string>(kFlutterWindowFnGetCurrentUserIdToken);

  std::unique_ptr<flutter::EncodableValue> arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
    {flutter::EncodableValue("forceRefresh"), flutter::EncodableValue(*in_force_refresh)},
  });

  std::unique_ptr<flutter::MethodResultFunctions<>> result_handler = std::make_unique<flutter::MethodResultFunctions<>>(
    [handle](const flutter::EncodableValue* value) {
      if (value == nullptr) {
        instance->future()->Complete(handle, 0);
      } else {
        instance->future()->CompleteWithResult(handle, 0, std::get<std::string>(*value));
      }
    },
    [handle](const std::string& error_code, const std::string& error_message, const void* error_details) {
      instance->future()->Complete(handle, -1, error_message.c_str());
    },
    [handle]() {
      instance->future()->Complete(handle, -2, "Not implemented.");
    }
  );

  instance->method_channel_auth->InvokeMethod("user.getIdToken", std::move(arguments), std::move(result_handler));
  if (out_future) {
    *out_future = firebase::Future<std::string>(instance->future(), handle.get());
  }

  return true;
}

bool FlutterWindow::GetCurrentUserUid(firebase::App* app, void* /*unused*/, void* out) {
  auto* out_string = static_cast<std::string*>(out);
  if (out_string) {
    out_string->clear();
  }
  if (!instance || !instance->user_uid.has_value()) {
    return false;
  }
  if (out_string) {
    *out_string = instance->user_uid.value();
  }
  return true;
}

firebase::ReferenceCountedFutureImpl* FlutterWindow::future() {
  return future_manager().GetFutureApi(this);
}
