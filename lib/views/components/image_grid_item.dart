import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:piwigo_ng/api/API.dart';

class ImageGridItem extends StatelessWidget {
  const ImageGridItem({
    Key key, this.isSelected, this.onLongPress, this.onTap, this.image
  }) : super(key: key);

  final bool isSelected;
  final dynamic image;
  final Function() onLongPress;
  final Function() onTap;


  @override
  Widget build(BuildContext context) {
    ThemeData _theme = Theme.of(context);

    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          border: isSelected ?
          Border.all(width: 5, color: _theme.colorScheme.primary) :
          Border.all(width: 0, color: Colors.white),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.network(image["derivatives"][API.prefs.getString('thumbnail_size')]["url"],
                fit: BoxFit.cover,
              ),
            ),
            isSelected ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Color(0x80000000),
            ) : Center(),
            /*
                        _isEditMode? Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: _isSelected(image['id']) ?
                              Icon(Icons.check_circle, color: _theme.floatingActionButtonTheme.backgroundColor) :
                              Icon(Icons.check_circle_outline, color: _theme.disabledColor),
                          ),
                        ) : Center(),

                         */
            API.prefs.getBool('show_thumbnail_title')? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Color(0x80ffffff),
                child: AutoSizeText('${image['name']}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 12),
                  maxFontSize: 14, minFontSize: 7,
                  textAlign: TextAlign.center,
                ),
              ),
            ) : Center(),

            // image["is_favorite"] == 1 ? Icon(
            //     Icons.favorite, color: Colors.red
            // ) : Center(),
          ],
        ),
      ),
    );
  }
}
//
// ButtonStyle ImageGridItemStyle(context) {
//   return ButtonStyle(
//     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//       RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//     backgroundColor: MaterialStateProperty.all(
//       Theme.of(context).colorScheme.primary
//     ),
//   );
// }
// ButtonStyle ImageGridItemStyleDisabled(context) {
//   return ButtonStyle(
//     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//       RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//     backgroundColor: MaterialStateProperty.all(
//       Theme.of(context).disabledColor
//     ),
//   );
// }
//
// class IconSwitch extends StatelessWidget {
//   const IconSwitch({Key key, this.isOnLeft, this.onTap}) : super(key: key);
//
//   final bool isOnLeft;
//   final Function() onTap;
//
//   List<BoxShadow> _switchIconShadow(bool isLeft) {
//     if(isLeft) {
//       if(isOnLeft) return [BoxShadow(
//           color: Colors.grey.withOpacity(0.5),
//           spreadRadius: 1,
//           blurRadius: 3,
//           offset: Offset(0, 1), // changes position of shadow
//         )];
//       else return [];
//     } else {
//       if(isOnLeft) return [];
//       else return [BoxShadow(
//         color: Colors.grey.withOpacity(0.5),
//         spreadRadius: 1,
//         blurRadius: 3,
//         offset: Offset(0, 1), // changes position of shadow
//       )];
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: Theme.of(context).inputDecorationTheme.fillColor,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: isOnLeft ? Theme.of(context).iconTheme.color : Colors.transparent,
//                 boxShadow: _switchIconShadow(true),
//               ),
//               child: Icon(Icons.apps_rounded,
//                   color: isOnLeft ? Colors.white : Theme.of(context).iconTheme.color
//               ),
//             ),
//             SizedBox(width: 5),
//             Container(
//               padding: EdgeInsets.all(5),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 color: isOnLeft ? Colors.transparent : Theme.of(context).iconTheme.color,
//                 boxShadow: _switchIconShadow(false),
//               ),
//               child: Icon(Icons.description_rounded,
//                   color: isOnLeft ? Theme.of(context).iconTheme.color : Colors.white
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class AnimatedIconButton extends StatefulWidget {
//   const AnimatedIconButton(this.icon, {Key key, this.isActive = false}) : super(key: key);
//
//   final Widget icon;
//   final bool isActive;
//
//   @override
//   _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
// }
//
// class _AnimatedIconButtonState extends State<AnimatedIconButton> with TickerProviderStateMixin {
//   Animation<double> _animation;
//   AnimationController _controller;
//
//   @override
//   void initState() {
//     _controller = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _animation = Tween<double>(
//       begin: 0,
//       end: -45,
//     ).animate(_controller);
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isActive) {
//       _controller.forward();
//     } else {
//       _controller.reverse();
//     }
//
//     return AnimatedBuilder(
//       animation: _controller,
//       child: widget.icon,
//       builder: (context, child) {
//         return Transform.rotate(
//           angle: _animation.value * (-pi / 90),
//           child: child,
//         );
//       },
//     );
//   }
// }

