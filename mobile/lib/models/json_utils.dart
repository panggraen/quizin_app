int toInt(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
bool toBool(dynamic v) => v == true || v == 1 || v == '1';
