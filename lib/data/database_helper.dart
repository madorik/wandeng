import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/climb_record.dart';
import '../models/gym.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wandeng.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE climb_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        visitor_id TEXT NOT NULL DEFAULT 'local_user',
        gym_name TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        tags TEXT DEFAULT '',
        video_path TEXT,
        thumbnail_path TEXT,
        recorded_at TEXT NOT NULL,
        duration INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE gyms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL DEFAULT '',
        lat REAL NOT NULL DEFAULT 0.0,
        lng REAL NOT NULL DEFAULT 0.0,
        rating REAL NOT NULL DEFAULT 0.0,
        crowd_status TEXT,
        has_parking INTEGER NOT NULL DEFAULT 0,
        has_shower INTEGER NOT NULL DEFAULT 0,
        has_endurance_wall INTEGER NOT NULL DEFAULT 0,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nickname TEXT NOT NULL DEFAULT '클라이머',
        height INTEGER,
        wingspan INTEGER,
        profile_image_path TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_records_date ON climb_records(recorded_at)');
    await db.execute(
        'CREATE INDEX idx_records_gym ON climb_records(gym_name)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_profile (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nickname TEXT NOT NULL DEFAULT '클라이머',
          height INTEGER,
          wingspan INTEGER,
          profile_image_path TEXT
        )
      ''');
    }
  }

  // ─── ClimbRecord CRUD ───

  Future<int> insertClimbRecord(ClimbRecord record) async {
    final db = await database;
    return await db.insert('climb_records', record.toMap());
  }

  Future<List<ClimbRecord>> getAllClimbRecords() async {
    final db = await database;
    final result =
        await db.query('climb_records', orderBy: 'recorded_at DESC');
    return result.map((map) => ClimbRecord.fromMap(map)).toList();
  }

  Future<List<ClimbRecord>> getClimbRecordsByDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDateKey(date);
    final result = await db.query(
      'climb_records',
      where: "recorded_at LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'recorded_at ASC',
    );
    return result.map((map) => ClimbRecord.fromMap(map)).toList();
  }

  Future<Map<String, List<ClimbRecord>>> getClimbRecordsByMonth(
      int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate =
        DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.query(
      'climb_records',
      where: 'recorded_at >= ? AND recorded_at <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'recorded_at ASC',
    );

    final Map<String, List<ClimbRecord>> grouped = {};
    for (final row in result) {
      final record = ClimbRecord.fromMap(row);
      final dateKey = _formatDateKey(record.recordedAt);
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }

  Future<ClimbRecord?> getClimbRecord(int id) async {
    final db = await database;
    final result = await db.query(
      'climb_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ClimbRecord.fromMap(result.first);
  }

  Future<int> updateClimbRecord(ClimbRecord record) async {
    final db = await database;
    return await db.update(
      'climb_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteClimbRecord(int id) async {
    final db = await database;
    return await db.delete(
      'climb_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ClimbRecord>> getRecentClimbRecords({int limit = 3}) async {
    final db = await database;
    final result = await db.query(
      'climb_records',
      orderBy: 'recorded_at DESC',
      limit: limit,
    );
    return result.map((map) => ClimbRecord.fromMap(map)).toList();
  }

  Future<int> getMonthlyClimbCount(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate =
        DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM climb_records WHERE recorded_at >= ? AND recorded_at <= ?',
      [startDate, endDate],
    );
    return result.first['count'] as int? ?? 0;
  }

  // ─── Gym CRUD ───

  Future<int> insertGym(Gym gym) async {
    final db = await database;
    return await db.insert('gyms', gym.toMap());
  }

  Future<List<Gym>> getAllGyms() async {
    final db = await database;
    final result = await db.query('gyms', orderBy: 'name ASC');
    return result.map((map) => Gym.fromMap(map)).toList();
  }

  Future<List<Gym>> searchGyms(String query) async {
    final db = await database;
    final result = await db.query(
      'gyms',
      where: 'name LIKE ? OR address LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Gym.fromMap(map)).toList();
  }

  Future<Gym?> getGym(int id) async {
    final db = await database;
    final result = await db.query(
      'gyms',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Gym.fromMap(result.first);
  }

  Future<List<Gym>> getFilteredGyms({
    String? search,
    bool? hasParking,
    bool? hasShower,
    bool? hasEnduranceWall,
  }) async {
    final db = await database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (search != null && search.isNotEmpty) {
      whereClauses.add('(name LIKE ? OR address LIKE ?)');
      whereArgs.addAll(['%$search%', '%$search%']);
    }
    if (hasParking == true) {
      whereClauses.add('has_parking = 1');
    }
    if (hasShower == true) {
      whereClauses.add('has_shower = 1');
    }
    if (hasEnduranceWall == true) {
      whereClauses.add('has_endurance_wall = 1');
    }

    final result = await db.query(
      'gyms',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'rating DESC',
    );
    return result.map((map) => Gym.fromMap(map)).toList();
  }

  /// 시드 데이터가 없으면 삽입
  Future<void> seedGymsIfEmpty(List<Gym> gyms) async {
    final db = await database;
    final count = (await db.rawQuery('SELECT COUNT(*) as c FROM gyms')).first['c'] as int;
    if (count > 0) return;
    final batch = db.batch();
    for (final gym in gyms) {
      batch.insert('gyms', gym.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// 암장별 기록 조회
  Future<List<ClimbRecord>> getClimbRecordsByGym(String gymName) async {
    final db = await database;
    final result = await db.query(
      'climb_records',
      where: 'gym_name = ?',
      whereArgs: [gymName],
      orderBy: 'recorded_at DESC',
    );
    return result.map((map) => ClimbRecord.fromMap(map)).toList();
  }

  /// 암장별 방문 횟수 맵
  Future<Map<String, int>> getGymVisitCounts() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT gym_name, COUNT(*) as count FROM climb_records GROUP BY gym_name ORDER BY count DESC',
    );
    return {
      for (final row in result) row['gym_name'] as String: row['count'] as int,
    };
  }

  // ─── UserProfile CRUD ───

  Future<UserProfile> getUserProfile() async {
    final db = await database;
    final result = await db.query('user_profile', limit: 1);
    if (result.isEmpty) {
      // 기본 프로필 생성
      final id = await db.insert('user_profile', const UserProfile().toMap());
      return UserProfile(id: id);
    }
    return UserProfile.fromMap(result.first);
  }

  Future<int> updateUserProfile(UserProfile profile) async {
    final db = await database;
    if (profile.id == null) {
      return await db.insert('user_profile', profile.toMap());
    }
    return await db.update(
      'user_profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ─── Helpers ───

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
