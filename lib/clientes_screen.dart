import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _cargoController = TextEditingController();

  String? _areaSeleccionada;
  DateTime? _fechaIngreso;
  bool _activo = true;
  String? _idSeleccionado;

  final List<String> _areas = ['Barista', 'Atención en Mesa', 'Caja', 'Administración'];
  List<Map<String, dynamic>> clientes = [];

  @override
  void initState() {
    super.initState();
    readEmpleados();
  }

  bool _validarCampos() {
    if (_nombreController.text.trim().isEmpty ||
        _dniController.text.trim().isEmpty ||
        _cargoController.text.trim().isEmpty ||
        _areaSeleccionada == null ||
        _fechaIngreso == null) {
      _mostrarMensaje('Por favor completa todos los campos.');
      return false;
    }

    final dni = _dniController.text.trim();
    if (dni.length != 8 || int.tryParse(dni) == null) {
      _mostrarMensaje('El DNI debe tener exactamente 8 dígitos numéricos.');
      return false;
    }

    return true;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _limpiarFormulario() {
    setState(() {
      _nombreController.clear();
      _dniController.clear();
      _cargoController.clear();
      _areaSeleccionada = null;
      _fechaIngreso = null;
      _activo = true;
      _idSeleccionado = null;
    });
  }

  Future<void> _createEmpleado() async {
    if (!_validarCampos()) return;
    final datos = {
      'nombreCompleto': _nombreController.text.trim(),
      'dni': _dniController.text.trim(),
      'area': _areaSeleccionada,
      'cargo': _cargoController.text.trim(),
      'fechaIngreso': _fechaIngreso,
      'activo': _activo,
    };
    try {
      await FirebaseFirestore.instance.collection('Empleados').add(datos);
      _limpiarFormulario();
      _mostrarMensaje('Empleado registrado exitosamente');
    } catch (e) {
      print('Error al crear empleado: $e');
    }
  }

  Future<void> readEmpleados() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('Empleados').get();
      setState(() {
        clientes = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      });
    } catch (e) {
      print('Error al leer empleados: $e');
    }
  }

  Future<void> updateEmpleado(String id) async {
    if (!_validarCampos()) return;
    final datos = {
      'nombreCompleto': _nombreController.text.trim(),
      'dni': _dniController.text.trim(),
      'area': _areaSeleccionada,
      'cargo': _cargoController.text.trim(),
      'fechaIngreso': _fechaIngreso,
      'activo': _activo,
    };
    try {
      await FirebaseFirestore.instance.collection('Empleados').doc(id).update(datos);
      _limpiarFormulario();
      _mostrarMensaje('Empleado actualizado correctamente');
    } catch (e) {
      print('Error al actualizar empleado: $e');
    }
  }

  Future<void> _deleteEmpleado(String id) async {
    try {
      await FirebaseFirestore.instance.collection('Empleados').doc(id).delete();
      _limpiarFormulario();
      await readEmpleados();
      _mostrarMensaje('Empleado eliminado');
    } catch (e) {
      print('Error al eliminar empleado: $e');
    }
  }

  Future<void> _seleccionarFechaIngreso(BuildContext context) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (fecha != null) {
      setState(() {
        _fechaIngreso = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Personal'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                icon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dniController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              decoration: const InputDecoration(
                labelText: 'DNI',
                icon: Icon(Icons.badge),
                counterText: "",
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _areaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Área de Trabajo',
                icon: Icon(Icons.work),
              ),
              items: _areas
                  .map((area) => DropdownMenuItem(
                        value: area,
                        child: Text(area),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _areaSeleccionada = value;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cargoController,
              decoration: const InputDecoration(
                labelText: 'Cargo (Ej. Barista Principal)',
                icon: Icon(Icons.assignment_ind),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(_fechaIngreso == null
                  ? 'Selecciona fecha de ingreso'
                  : 'Ingreso: ${_fechaIngreso!.day}/${_fechaIngreso!.month}/${_fechaIngreso!.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _seleccionarFechaIngreso(context),
              ),
            ),
            SwitchListTile(
              title: const Text('¿Empleado Activo?'),
              value: _activo,
              onChanged: (value) {
                setState(() {
                  _activo = value;
                });
              },
              secondary: Icon(
                _activo ? Icons.check_circle : Icons.cancel,
                color: _activo ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (_idSeleccionado == null) {
                  _createEmpleado();
                } else {
                  updateEmpleado(_idSeleccionado!);
                }
              },
              icon: Icon(_idSeleccionado == null ? Icons.add : Icons.save),
              label: Text(_idSeleccionado == null ? 'Agregar Empleado' : 'Actualizar Empleado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _idSeleccionado == null ? Colors.brown : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            const Text(
              'Lista de Empleados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Empleados').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hay empleados registrados.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final empleado = docs[index];
                    final data = empleado.data() as Map<String, dynamic>;
                    DateTime fechaIngreso;
                    if (data['fechaIngreso'] is Timestamp) {
                      fechaIngreso = (data['fechaIngreso'] as Timestamp).toDate();
                    } else if (data['fechaIngreso'] is DateTime) {
                      fechaIngreso = data['fechaIngreso'];
                    } else {
                      fechaIngreso = DateTime.now();
                    }
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, color: Colors.brown),
                        title: Text(data['nombreCompleto'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DNI: ${data['dni'] ?? ''}'),
                            Text('Área: ${data['area'] ?? ''}'),
                            Text('Cargo: ${data['cargo'] ?? ''}'),
                            Text('Ingreso: ${fechaIngreso.day}/${fechaIngreso.month}/${fechaIngreso.year}'),
                            Text('Estado: ${data['activo'] == true ? 'Activo' : 'Inactivo'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _idSeleccionado = empleado.id;
                                  _nombreController.text = data['nombreCompleto'] ?? '';
                                  _dniController.text = data['dni'] ?? '';
                                  _areaSeleccionada = data['area'];
                                  _cargoController.text = data['cargo'] ?? '';
                                  _fechaIngreso = fechaIngreso;
                                  _activo = data['activo'] ?? true;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEmpleado(empleado.id),
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