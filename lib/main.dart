import 'package:flutter/material.dart';
import 'package:guia5/database_helper.dart';
import 'libros.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FLutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 151, 9, 9),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _EditTituloLibro = TextEditingController();
  List<Libro> _items = [];

  @override
  void initState() {
    super.initState();
    _cargarListaLibros();
  }

  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems();
    setState(() {
      _items = items;
    });
  }

  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);
    await _dbHelper.insertLibro(nuevoLibro);
    print("SE AGREGÓ EL NUEVO LIBRO");
    _cargarListaLibros();
  }

  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Título"),
          content: TextField(
            controller: _EditTituloLibro,
            decoration: const InputDecoration(hintText: "Ingrese el titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  _agregarNuevoLibro(_EditTituloLibro.text.toString());
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();
  }

  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text(
            "¿Estas seguro de que quieres eliminar este libro?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id);
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbHelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController _tituloController = TextEditingController(
      text: tituloActual,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modificar Titulo del Libro"),
          content: TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              hintText: "Escribe el nuevo título",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, _tituloController.text.toString());
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final libro = _items[index];
          return ListTile(
            title: Text(libro.tituloLibro),
            subtitle: Text('ID: ${libro.id}'),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: () {
                _mostrarMensajeModificar(libro.id!);
              },
            ),
            onTap: () {
              _ventanaEditar(libro.id!, libro.tituloLibro);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarVentanaAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
