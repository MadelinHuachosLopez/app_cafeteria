import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Error al inicializar Firebase: $e");
  }

  runApp(const MiCafeteriaApp());
}

class MiCafeteriaApp extends StatelessWidget {
  const MiCafeteriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MI CAFETERIA APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const PantallaCafeteria(),
    );
  }
}

class PantallaCafeteria extends StatefulWidget {
  const PantallaCafeteria({super.key});

  @override
  State<PantallaCafeteria> createState() => _PantallaCafeteriaState();
}

class _PantallaCafeteriaState extends State<PantallaCafeteria> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  CollectionReference get _productosRef =>
      FirebaseFirestore.instance.collection('productos');

  void _mostrarFormulario([DocumentSnapshot? documentSnapshot]) {
    if (documentSnapshot != null) {
      _nombreController.text = documentSnapshot['nombre'] ?? '';
      _precioController.text = documentSnapshot['precio'].toString();
    } else {
      _nombreController.clear();
      _precioController.clear();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                documentSnapshot == null ? 'Agregar Producto' : 'Editar Producto',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              TextField(
                controller: _precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio (S/)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: Text(documentSnapshot == null ? 'Guardar' : 'Actualizar'),
                onPressed: () async {
                  final String nombre = _nombreController.text;
                  final double? precio = double.tryParse(_precioController.text);

                  if (nombre.isNotEmpty && precio != null) {
                    if (documentSnapshot == null) {
                      await _productosRef.add({"nombre": nombre, "precio": precio});
                    } else {
                      await _productosRef
                          .doc(documentSnapshot.id)
                          .update({"nombre": nombre, "precio": precio});
                    }

                    _nombreController.clear();
                    _precioController.clear();
                    if (mounted) Navigator.of(context).pop();
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _eliminarProducto(String productoId) async {
    await _productosRef.doc(productoId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MI CAFETERIA APP'),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productosRef.snapshots(),
        builder: (context, streamSnapshot) {
          if (streamSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error de conexión:\n${streamSnapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (streamSnapshot.hasData) {
            if (streamSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No hay productos registrados.'),
              );
            }
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    title: Text(
                      documentSnapshot['nombre'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('S/ ${documentSnapshot['precio']}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostrarFormulario(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarProducto(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: Colors.deepOrangeAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}