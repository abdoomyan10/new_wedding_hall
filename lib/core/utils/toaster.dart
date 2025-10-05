/*import 'package:flutter/material.dart';
import 'package:wedding_hall/core/extensions/context_extention.dart';

class Toaster {
  Toaster._();

  static void showToast(String text, {bool isError = true}) {
    BotToast.showCustomText(
      toastBuilder: (cancelFunc) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isError ? Icons.warning_amber_rounded : Icons.done,
                  color: isError ? const Color(0xff9F1C48) : Colors.green,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isError ? const Color(0xff9F1C48) : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showLoading() {
    BotToast.showCustomLoading(
      animationDuration: Durations.medium1,
      toastBuilder: (cancelFunc) {
        return Builder(
          builder: (context) {
            return Card(
              color: context.scaffoldBackgroundColor,
              child: Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(12),
                child: const CustomLoadingWidget(),
              ),
            ).animate().scale();
          },
        );
      },
    );
  }

  static void closeLoading() {
    BotToast.closeAllLoading();
  }
}

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({super.key, this.width, this.height});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CircularProgressIndicator(),
    );
  }
}*/
