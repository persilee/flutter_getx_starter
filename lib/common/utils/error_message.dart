// 实现本节独立示例，按前面说明的文件位置接入工程。

String userFacingErrorMessage(Object error, {String fallback = 'Error'}) =>
    error is Exception ? error.toString() : fallback;
