import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _porcion = TextEditingController();

  String? _categoriaSeleccionada;
  bool _disponible = true;
  String? _idSeleccionado;

  final List<String> _categorias = [
    'Café Caliente',
    'Café Frío',
    'Postres',
    'Bocaditos',
    'Bebidas'
  ];

  List<Map<String, dynamic>> productos = [];

  @override
  void initState() {
    super.initState();
    readProductos();
  }

  bool _validarCampos() {
    if (_nombre.text.trim().isEmpty ||
        _precio.text.trim().isEmpty ||
        _porcion.text.trim().isEmpty ||
        _categoriaSeleccionada == null) {
      _mostrarMensaje('Por favor completa todos los campos.');
      return false;
    }

    final precioParsed = double.tryParse(_precio.text.trim());
    if (precioParsed == null || precioParsed <= 0) {
      _mostrarMensaje('Ingrese un precio válido y mayor a 0.');
      return false;
    }

    return true;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void limpiarFormulario() {
    setState(() {
      _nombre.clear();
      _precio.clear();
      _porcion.clear();
      _categoriaSeleccionada = null;
      _disponible = true;
      _idSeleccionado = null;
    });
  }

  Future<void> createProductos() async {
    if (!_validarCampos()) return;
    final datos = {
      'nombre': _nombre.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'porcion': _porcion.text.trim(),
      'categoria': _categoriaSeleccionada,
      'disponible': _disponible,
    };
    try {
      await FirebaseFirestore.instance.collection('Productos').add(datos);
      limpiarFormulario();
      _mostrarMensaje('Producto agregado correctamente');
    } catch (e) {
      print('Error al crear producto: $e');
    }
  }

  Future<void> readProductos() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Productos').get();
      setState(() {
        productos = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error al leer productos: $e');
    }
  }

  Future<void> updateProductos(String id) async {
    if (!_validarCampos()) return;
    final datos = {
      'nombre': _nombre.text.trim(),
      'precio': double.tryParse(_precio.text.trim()) ?? 0.0,
      'porcion': _porcion.text.trim(),
      'categoria': _categoriaSeleccionada,
      'disponible': _disponible,
    };
    try {
      await FirebaseFirestore.instance.collection('Productos').doc(id).update(datos);
      limpiarFormulario();
      _mostrarMensaje('Producto actualizado correctamente');
    } catch (e) {
      print('Error al actualizar productos: $e');
    }
  }

  Future<void> deleteProductos(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Productos').doc(id).delete();
      limpiarFormulario();
      await readProductos();
      _mostrarMensaje('Producto eliminado');
    } catch (e) {
      print('Error al eliminar producto: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Menú - Cafetería'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: "Nombre del café / producto",
                icon: Icon(Icons.coffee_maker),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precio,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Precio (S/.)",
                icon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _porcion,
              decoration: const InputDecoration(
                labelText: "Tamaño / Presentación (Ej: 12 oz, Porción)",
                icon: Icon(Icons.local_cafe),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              items: _categorias.map((categoria) {
                return DropdownMenuItem(
                  value: categoria,
                  child: Text(categoria),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Categoría',
                icon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('¿Disponible para venta?'),
              value: _disponible,
              onChanged: (value) {
                setState(() {
                  _disponible = value;
                });
              },
              secondary: Icon(
                _disponible ? Icons.check_circle : Icons.cancel,
                color: _disponible ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (_idSeleccionado == null) {
                  createProductos();
                } else {
                  updateProductos(_idSeleccionado!);
                }
              },
              icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
              label: Text(_idSeleccionado == null ? 'Agregar Producto' : 'Actualizar Producto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _idSeleccionado == null ? Colors.brown : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text(
              'Catálogo de Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Productos').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay productos registrados.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final producto = docs[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.coffee, color: Colors.brown),
                        title: Text(producto['nombre']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Precio: S/. ${producto['precio']}'),
                            Text('Tamaño: ${producto['porcion']}'),
                            Text('Categoría: ${producto['categoria']}'),
                            Text('Estado: ${producto['disponible'] ? 'Disponible' : 'Agotado'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _idSeleccionado = producto.id;
                                  _nombre.text = producto['nombre'];
                                  _precio.text = producto['precio'].toString();
                                  _porcion.text = producto['porcion'];
                                  _categoriaSeleccionada = producto['categoria'];
                                  _disponible = producto['disponible'];
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProductos(producto.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}