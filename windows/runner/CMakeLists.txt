cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

include(FetchContent)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
        "flutter_window.cpp"
        "main.cpp"
        "utils.cpp"
        "win32_window.cpp"
        "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
        "Runner.rc"
        "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Firebase App Check
if (NOT DEFINED FIREBASE_CPP_SDK_DIR)
    set(FIREBASE_CPP_SDK_DIR "${CMAKE_BINARY_DIR}/extracted/firebase_cpp_sdk_windows")
endif ()
set(FIREBASE_INCLUDE_DIR, "${FIREBASE_CPP_SDK_DIR}/include")

string(TOLOWER "${CMAKE_BUILD_TYPE}" BUILD_TYPE_LOWER)
if (BUILD_TYPE_LOWER STREQUAL "debug")
    set(FIREBASE_BUILD_SUBDIR "Debug")
else ()
    set(FIREBASE_BUILD_SUBDIR "Release")
endif ()

if (NOT DEFINED MSVC_RUNTIME_MODE)
    set(MSVC_RUNTIME_MODE MD)
endif ()

target_compile_definitions(${BINARY_NAME} PRIVATE -DINTERNAL_EXPERIMENTAL=1)
target_include_directories(${BINARY_NAME} PRIVATE "${FIREBASE_INCLUDE_DIR}")

add_library(Firebase::App STATIC IMPORTED)
set_target_properties(Firebase::App PROPERTIES
        IMPORTED_LOCATION_DEBUG "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Debug/firebase_app.lib"
        IMPORTED_LOCATION_PROFILE "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Release/firebase_app.lib"
        IMPORTED_LOCATION_RELEASE "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Release/firebase_app.lib"
        INTERFACE_LINK_LIBRARIES Firebase::App
        INTERFACE_INCLUDE_DIRECTORIES "${FIREBASE_INCLUDE_DIR}"
)

add_library(Firebase::AppCheck STATIC IMPORTED)
set_target_properties(Firebase::AppCheck PROPERTIES
        IMPORTED_LOCATION_DEBUG "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Debug/firebase_app_check.lib"
        IMPORTED_LOCATION_PROFILE "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Release/firebase_app_check.lib"
        IMPORTED_LOCATION_RELEASE "${FIREBASE_CPP_SDK_DIR}/libs/windows/VS2019/${MSVC_RUNTIME_MODE}/x64/Release/firebase_app_check.lib"
        INTERFACE_LINK_LIBRARIES Firebase::AppCheck
        INTERFACE_INCLUDE_DIRECTORIES "${FIREBASE_INCLUDE_DIR}"
)

target_link_libraries(${BINARY_NAME} PRIVATE Firebase::AppCheck Firebase::App)

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
