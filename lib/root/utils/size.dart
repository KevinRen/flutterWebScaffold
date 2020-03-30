import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class AppSize {
  static Image sizeImage(String src, double width, double height) {
    if (src.isEmpty) {
      return null;
    } else {
      return Image.asset(
        src,
        fit: BoxFit.cover,
        width: size(width),
        height: size(height),
      );
    }
  }

  static setDesignSize(context, { double width: 1920, double height: 1080 }) {
    ScreenUtil.init(context, width: width, height: height, allowFontScaling: false);
  }

  /// 按宽度比例计算尺寸
  static double size(size) => ScreenUtil().setWidth(size);

  static double fontSize(size) => ScreenUtil().setSp(size);

  /// 设备宽度
  static double screenWidth() => ScreenUtil.screenWidth;

  /// 设备高度
  static double screenHeight() => ScreenUtil.screenHeight;

  /// 底部安全区距离
  static double bottomBarHeight() => ScreenUtil.bottomBarHeight;

  /// 状态栏高度
  static double statusBarHeight() => ScreenUtil.statusBarHeight;
}