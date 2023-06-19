import 'package:flutter/material.dart';
import 'package:piwigo_ng/models/image_model.dart';
import 'package:piwigo_ng/utils/settings.dart';

class ImageCommentDialog extends StatefulWidget {
  const ImageCommentDialog({Key? key, required this.image}) : super(key: key);

  final ImageModel image;

  @override
  State<ImageCommentDialog> createState() => _ImageCommentDialogState();
}

class _ImageCommentDialogState extends State<ImageCommentDialog> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    _controller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isScrolled = false;
    bool isNameHidden = false;
    if (_controller.positions.isNotEmpty) {
      isScrolled = _controller.offset > 0.0;
      isNameHidden = _controller.offset > 40.0 / 2;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Settings.modalMaxWidth,
      ),
      child: AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
        titlePadding: EdgeInsets.zero,
        title: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
          ),
          primary: false,
          elevation: isScrolled ? 5.0 : 0.0,
          toolbarHeight: 40.0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close),
          ),
          title: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            opacity: isNameHidden ? 1.0 : 0.0,
            child: Text(
              widget.image.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        content: SingleChildScrollView(
          controller: _controller,
          padding: EdgeInsets.only(
            top: 8.0,
            right: 16.0,
            left: 16.0,
            bottom: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.image.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Divider(
                color: Theme.of(context).disabledColor,
              ),
              Text(
                // "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tempor, eros eget ultrices tincidunt, lacus quam tempor neque, eu venenatis tellus nulla sit amet lectus. Praesent lacus orci, fermentum a elit vitae, cursus iaculis sapien. Sed ac ipsum ante. In efficitur urna sed pulvinar accumsan. Aliquam et condimentum ex. Quisque eleifend ipsum vitae magna gravida, eget maximus nisi posuere. Maecenas a dui et est posuere sollicitudin ac eget tellus. In quis est purus. Cras eget vestibulum justo. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed vel elit in sapien bibendum porta. In eget felis auctor, tincidunt lectus sed, placerat lectus. Vivamus ac mauris sit amet turpis mollis tempor.Donec metus nunc, ultricies id lobortis sed, accumsan varius nunc. Duis et posuere ex. Donec ante urna, ornare non elit ac, egestas condimentum ex. Curabitur aliquam nec purus a hendrerit. Nam metus massa, aliquam eu ligula a, pretium maximus orci. Morbi eros arcu, egestas et lorem et, mattis posuere ex. In at lacus erat. Mauris aliquam lectus eget dui pretium faucibus. Ut mollis elit at orci tempor rutrum. Fusce tincidunt libero nisi, nec efficitur odio laoreet in. Interdum et malesuada fames ac ante ipsum primis in faucibus. Aliquam consequat massa feugiat, rutrum eros sed, blandit nunc. Duis ac eleifend turpis. Interdum et malesuada fames ac ante ipsum primis in faucibus. Etiam malesuada scelerisque purus vitae auctor. Etiam ut rhoncus eros.Pellentesque eget velit vel massa ultricies vestibulum quis in orci. Vivamus porttitor libero at elit dignissim, ut iaculis lorem placerat. Vivamus sed nisl turpis. Sed dictum enim a rhoncus lacinia. Pellentesque non finibus massa. Aenean leo diam, elementum et turpis a, placerat laoreet libero. Proin eu euismod felis, at laoreet augue. Vestibulum lobortis sapien ac scelerisque hendrerit.Etiam lacinia tempus erat, sed semper turpis ultrices ut. Aliquam erat volutpat. Aenean semper venenatis rhoncus. Cras sollicitudin ullamcorper ante, id placerat lacus facilisis id. Donec a metus consequat, accumsan ipsum a, tincidunt mi. Donec ullamcorper rhoncus augue, sed dapibus urna. Ut sed interdum arcu. Aliquam sagittis pulvinar feugiat. Maecenas sed auctor lectus, quis dapibus nisi. Etiam ac ullamcorper nulla, eget porttitor eros. Mauris varius lorem magna, eget ultrices lacus vestibulum in. Sed magna nulla, bibendum et orci et, placerat ultricies orci. Morbi consequat arcu odio, eget tristique purus porttitor non. Mauris ac egestas dolor. Nulla nec aliquam quam. Suspendisse consectetur ex non elementum maximus.Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Maecenas accumsan ante mattis nisi maximus, in feugiat metus pretium. Nam at porttitor purus, a cursus dolor. Etiam luctus eleifend hendrerit. Phasellus at mauris vulputate, volutpat neque vitae, laoreet massa. Nullam feugiat felis nec mi feugiat mollis. Phasellus consequat luctus dictum. Aliquam erat volutpat. In hac habitasse platea dictumst. Donec fringilla eleifend lorem. Aliquam erat volutpat. Pellentesque in elit vitae arcu maximus viverra. Donec accumsan lectus non bibendum pretium.",
                widget.image.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
