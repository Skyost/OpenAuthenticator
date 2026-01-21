import 'package:flutter/material.dart';
import 'package:open_authenticator/i18n/translations.g.dart';
import 'package:open_authenticator/spacing.dart';
import 'package:open_authenticator/widgets/sized_scalable_image.dart';
import 'package:open_authenticator/widgets/title.dart';

/// Allows to display an image, followed by a text and some buttons.
class ImageTextButtonsWidget extends StatelessWidget {
  /// The image size.
  static const double _kImageSize = 80;

  /// The image.
  final Widget image;

  /// The message to display.
  final String? text;

  /// The buttons.
  final List<Widget> buttons;

  /// Creates a new image text buttons instance.
  const ImageTextButtonsWidget({
    super.key,
    required this.image,
    this.text,
    this.buttons = const [],
  });

  /// Creates a new image text buttons instance from an asset.
  const ImageTextButtonsWidget.asset({
    Key? key,
    required String asset,
    String? text,
    List<Widget> buttons = const [],
  }) : this(
         key: key,
         image: const SizedScalableImageWidget(
           height: _kImageSize,
           asset: 'assets/images/home.si',
         ),
         text: text,
         buttons: buttons,
       );

  /// Creates a new image text buttons instance from an icon.
  ImageTextButtonsWidget.icon({
    Key? key,
    required IconData icon,
    String? text,
    List<Widget> buttons = const [],
  }) : this(
         key: key,
         image: AppTitleGradient(
           child: Icon(
             icon,
             size: _kImageSize,
           ),
         ),
         text: text,
         buttons: buttons,
       );

  @override
  Widget build(BuildContext context) => Center(
    child: ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(kBigSpace),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: kBigSpace),
          child: image,
        ),
        Padding(
          padding: EdgeInsets.only(bottom: buttons.isEmpty ? 0 : kBigSpace),
          child: Text(
            text ?? translations.error.generic.noTryAgain,
            textAlign: TextAlign.center,
          ),
        ),
        for (int i = 0; i < buttons.length; i++)
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: i == buttons.length - 1 ? 0 : kSpace),
              child: buttons[i],
            ),
          ),
      ],
    ),
  );
}
