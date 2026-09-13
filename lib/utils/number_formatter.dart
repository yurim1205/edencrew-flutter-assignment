abstract final class NumberFormatter {
  // 172100 -> "172,100"
  static String comma(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]},',
        );
  }

  // 29113466 -> "29,113천"
  static String volumeInThousands(int value) {
    final int thousands = value ~/ 1000;
    return '${comma(thousands)}천';
  }

  // 1063000000000000 -> "1,063조"
  static String marketCapInJo(int value) {
    final int jo = value ~/ 1000000000000;
    return '${comma(jo)}조';
  } 

  // "20260911" -> "09.11"
  static String dateMMDD(String yyyymmdd) {
    if (yyyymmdd.length != 8) return yyyymmdd;
    final String mm = yyyymmdd.substring(4, 6);
    final String dd = yyyymmdd.substring(6, 8);
    return '$mm.$dd';
   }
}