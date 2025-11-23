import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/atendimento_model.dart';
import '../../domain/entities/atendimento.dart';

class DatabaseHelper {
  static const _databaseName = "atendimentos.db";
  static const _databaseVersion = 1;

  static const tableAtendimentos = 'atendimentos';
  static const columnId = 'id';
  static const columnDescricao = 'descricao';
  static const columnStatus = 'status';
  static const columnImagemPath = 'imagemPath';
  static const columnAnotacoes = 'anotacoes';
  static const columnDataCriacao = 'dataCriacao';
  static const columnDataAtualizacao = 'dataAtualizacao';

  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance ??= DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableAtendimentos (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDescricao TEXT NOT NULL,
        $columnStatus INTEGER NOT NULL,
        $columnImagemPath TEXT,
        $columnAnotacoes TEXT,
        $columnDataCriacao TEXT NOT NULL,
        $columnDataAtualizacao TEXT
      )
    ''');
    print("✅ Banco de dados criado com sucesso!");
  }

  // === MÉTODOS QUE ESTAVAM FALTANDO - COLE ESTA PARTE ===

  Future<int> insertAtendimento(AtendimentoModel atendimento) async {
    final db = await database;
    return await db.insert(tableAtendimentos, atendimento.toMap());
  }

  Future<List<AtendimentoModel>> getAtendimentos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAtendimentos,
      where: '$columnStatus != ?',
      whereArgs: [StatusAtendimento.deletado.index],
    );
    return List.generate(maps.length, (i) {
      return AtendimentoModel.fromMap(maps[i]);
    });
  }

  Future<List<AtendimentoModel>> getAtendimentosPorStatus(StatusAtendimento status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAtendimentos,
      where: '$columnStatus = ?',
      whereArgs: [status.index],
    );
    return List.generate(maps.length, (i) {
      return AtendimentoModel.fromMap(maps[i]);
    });
  }
  Future<int> deleteAtendimento(int id) async {
    final db = await database;
    return await db.update(
      tableAtendimentos,
      {
        columnStatus: StatusAtendimento.deletado.index,
        columnDataAtualizacao: DateTime.now().toIso8601String(),
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<AtendimentoModel?> getAtendimentoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAtendimentos,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AtendimentoModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> testDatabase() async {
    await database;
    print("✅ Conexão com banco estabelecida!");
 
  }
  Future<int> updateAtendimentoWithImage(int id, String imagemPath) async {
  final db = await database;
  return await db.update(
    tableAtendimentos,
    {
      columnImagemPath: imagemPath,
      columnDataAtualizacao: DateTime.now().toIso8601String(),
    },
    where: '$columnId = ?',
    whereArgs: [id],
  );
}
 Future<int> updateAtendimento(AtendimentoModel atendimento) async {
  final db = await database;
  print('💾 Tentando atualizar atendimento ID: ${atendimento.id}');
  
  final result = await db.update(
    tableAtendimentos,
    atendimento.toMap(),
    where: '$columnId = ?',
    whereArgs: [atendimento.id],
  );
  
  print('📊 Resultado da atualização: $result linhas afetadas');
  return result;
}
 

Future<int> testFinalizarAtendimento(int id) async {
  final db = await database;
  print("🟡 [DEBUG] Teste direto no banco - Finalizando atendimento ID: $id");
  
  final result = await db.update(
    tableAtendimentos,
    {
      columnStatus: StatusAtendimento.finalizado.index,
      columnDataAtualizacao: DateTime.now().toIso8601String(),
    },
    where: '$columnId = ?',
    whereArgs: [id],
  );
  
  print("🟡 [DEBUG] Teste direto - Resultado: $result linhas afetadas");
  return result;
}
 
  }
