import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final TextEditingController _razonSocial = TextEditingController();
  final TextEditingController _ruc = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _contacto = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String? _categoriaSeleccionada;
  String? _idSeleccionado;

  final List<String> _categorias = [
    'Grano de Café',
    'Lácteos',
    'Repostería',
    'Empaques y Desechables',
    'Insumos Varios'
  ];

  List<Map<String, dynamic>> proveedores = [];

  @override
  void initState() {
    super.initState();
    readProveedores();
  }

  bool _validarCampos() {
    if (_razonSocial.text.trim().isEmpty ||
        _ruc.text.trim().isEmpty ||
        _direccion.text.trim().isEmpty ||
        _contacto.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _categoriaSeleccionada == null) {
      _mostrarMensaje('Por favor completa todos los campos.');
      return false;
    }

    final rucText = _ruc.text.trim();
    if (rucText.length != 11 || int.tryParse(rucText) == null) {
      _mostrarMensaje('El RUC debe contener exactamente 11 dígitos numéricos.');
      return false;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_email.text.trim())) {
      _mostrarMensaje('Ingrese un correo electrónico válido.');
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
      _razonSocial.clear();
      _ruc.clear();
      _direccion.clear();
      _contacto.clear();
      _email.clear();
      _categoriaSeleccionada = null;
      _idSeleccionado = null;
    });
  }

  Future<void> createProveedor() async {
    if (!_validarCampos()) return;
    final datos = {
      'razon_social': _razonSocial.text.trim(),
      'ruc': _ruc.text.trim(),
      'direccion': _direccion.text.trim(),
      'contacto': _contacto.text.trim(),
      'email': _email.text.trim(),
      'categoria': _categoriaSeleccionada,
    };
    try {
      await FirebaseFirestore.instance.collection('Proveedores').add(datos);
      limpiarFormulario();
      _mostrarMensaje('Proveedor guardado correctamente');
    } catch (e) {
      print('Error al crear proveedor: $e');
    }
  }

  Future<void> readProveedores() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Proveedores').get();
      setState(() {
        proveedores = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error al leer proveedores: $e');
    }
  }

  Future<void> updateProveedor(String id) async {
    if (!_validarCampos()) return;
    final datos = {
      'razon_social': _razonSocial.text.trim(),
      'ruc': _ruc.text.trim(),
      'direccion': _direccion.text.trim(),
      'contacto': _contacto.text.trim(),
      'email': _email.text.trim(),
      'categoria': _categoriaSeleccionada,
    };
    try {
      await FirebaseFirestore.instance.collection('Proveedores').doc(id).update(datos);
      limpiarFormulario();
      _mostrarMensaje('Proveedor actualizado correctamente');
    } catch (e) {
      print('Error al actualizar proveedor: $e');
    }
  }

  Future<void> deleteProveedor(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Proveedores').doc(id).delete();
      limpiarFormulario();
      await readProveedores();
      _mostrarMensaje('Proveedor eliminado');
    } catch (e) {
      print('Error al eliminar proveedor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Proveedores'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _razonSocial,
              decoration: const InputDecoration(
                labelText: 'Razón Social / Distribuidora',
                icon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ruc,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: const InputDecoration(
                labelText: 'RUC',
                icon: Icon(Icons.confirmation_number),
                counterText: "",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _direccion,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                icon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contacto,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono / Contacto',
                icon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email de pedidos',
                icon: Icon(Icons.email),
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
                labelText: 'Suministro / Categoría',
                icon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (_idSeleccionado == null) {
                  createProveedor();
                } else {
                  updateProveedor(_idSeleccionado!);
                }
              },
              icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
              label: Text(_idSeleccionado == null ? 'Agregar Proveedor' : 'Actualizar Proveedor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _idSeleccionado == null ? Colors.brown : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text(
              'Lista de Proveedores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Proveedores').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay proveedores registrados.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final proveedor = docs[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.store, color: Colors.brown),
                        title: Text(proveedor['razon_social']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RUC: ${proveedor['ruc']}'),
                            Text('Dirección: ${proveedor['direccion']}'),
                            Text('Contacto: ${proveedor['contacto']}'),
                            Text('Email: ${proveedor['email']}'),
                            Text('Categoría: ${proveedor['categoria']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _idSeleccionado = proveedor.id;
                                  _razonSocial.text = proveedor['razon_social'];
                                  _ruc.text = proveedor['ruc'];
                                  _direccion.text = proveedor['direccion'];
                                  _contacto.text = proveedor['contacto'];
                                  _email.text = proveedor['email'];
                                  _categoriaSeleccionada = proveedor['categoria'];
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProveedor(proveedor.id),
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