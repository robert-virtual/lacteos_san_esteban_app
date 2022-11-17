import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lacteos_san_esteban_app/models/venta.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class VentasPage extends StatelessWidget {
  VentasPage({super.key, this.cliente, this.empleado});
  DocumentReference<Persona>? cliente;
  DocumentReference<Persona>? empleado;
  var rxEmpleado = Rx<DocumentReference<Persona>?>(null);
  var rxCliente = Rx<DocumentReference<Persona>?>(null);
  var rxFechaInicial = Rx<Timestamp?>(null);
  var rxFechaFinal = Rx<Timestamp?>(null);
  final pdf = pw.Document();
  final ventas = <Venta>[].obs;
  final formatDateTime = DateFormat("dd MMM yyyy h:mm a");
  final formatDate = DateFormat("dd/MM/yyyy");
  final formatDatePdf = DateFormat("dd-MM-yyyy-h-mm-a");
  final ventasCollection = FirebaseFirestore.instance
      .collection("ventas")
      .withConverter<Venta>(
          fromFirestore: (snap, _) => Venta.fromJson(snap.data()!),
          toFirestore: (venta, _) => venta.toJson());
  @override
  Widget build(BuildContext context) {
    if (empleado != null) {
      rxEmpleado.value = empleado;
    }
    if (cliente != null) {
      rxCliente.value = cliente;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas"),
        actions: [
          TextButton(
            onPressed: () async {
              pdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    final boldText =
                        pw.TextStyle(fontWeight: pw.FontWeight.bold);
                    var items = <pw.TableRow>[
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text("Cliente", style: boldText),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text("Empleado", style: boldText),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(2.0),
                            child: pw.Text("Fecha", style: boldText),
                          )
                        ],
                      )
                    ];
                    items.addAll(
                      ventas.value.map(
                        (e) => pw.TableRow(
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(e.cliente.id)),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(2.0),
                                child: pw.Text(e.empleado.id)),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(2.0),
                              child: pw.Text(
                                formatDate.format(
                                  e.fecha.toDate(),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                    /* final imageProvider = */
                    /*     Image.asset("/images/san_esteban.jpg").image; */
                    /* final image = pw.Image(imageProvider); */
                    return pw.ListView(
                      children: [
                        pw.Text(
                          "Lacteos san esteban",
                          style: pw.TextStyle(
                              fontSize: 25.0, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 10.0),
                        pw.Table(
                          children: items,
                          border: pw.TableBorder.all(width: 1.0),
                        )
                      ],
                    );
                  },
                ),
              );
              final documents = await getApplicationDocumentsDirectory();
              print("documents path: ${documents.path}");
              final filePath =
                  "${documents.path}/informe de ventas ${formatDatePdf.format(DateTime.now())}";
              try {
                final file = File(filePath);
                await file.writeAsBytes(await pdf.save());
              } catch (e) {
                print(e);
              }
              OpenFilex.open(filePath);
            },
            child: Text(
              "Guardar PDF",
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          )
        ],
      ),
      body: Obx(() => StreamBuilder(
          stream: ventasCollection
              .where("cliente", isEqualTo: rxCliente.value)
              .where("empleado", isEqualTo: rxEmpleado.value)
              .where("fecha", isLessThanOrEqualTo: rxFechaInicial.value)
              .where("fecha", isGreaterThanOrEqualTo: rxFechaFinal.value)
              .orderBy("fecha", descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              print("Snap Error: ${snap.error}");
              return const Center(
                child: Text("Ups ha ocurrido un error"),
              );
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            ventas.value = snap.data!.docs.map((e) => e.data()).toList();
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  primary: false,
                  automaticallyImplyLeading: false,
                  title: Text("${snap.data!.docs.length} Resultados"),
                  actions: [
                    Wrap(
                      spacing: 2.0,
                      children: [
                        Visibility(
                          visible: rxEmpleado.value != null,
                          child: ChoiceChip(
                            label: Row(
                              children: [
                                Text(rxEmpleado.value != null
                                    ? rxEmpleado.value!.id.substring(0, 10)
                                    : "Empleado"),
                                const Icon(Icons.close)
                              ],
                            ),
                            selected: rxEmpleado.value != null,
                            onSelected: (value) {
                              if (!value) {
                                rxEmpleado.value = null;
                              }
                            },
                          ),
                        ),
                        Visibility(
                          visible: rxCliente.value != null,
                          child: ChoiceChip(
                            label: Row(
                              children: [
                                Text(rxCliente.value != null
                                    ? rxCliente.value!.id.substring(0, 10)
                                    : "Cliente"),
                                const Icon(Icons.close)
                              ],
                            ),
                            selected: rxCliente.value != null,
                            onSelected: (value) {
                              if (!value) {
                                rxCliente.value = null;
                              }
                            },
                          ),
                        ),
                        ChoiceChip(
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Fecha"),
                              Icon(
                                rxFechaInicial.value != null
                                    ? Icons.close
                                    : Icons.expand_more,
                              )
                            ],
                          ),
                          selected: rxFechaFinal.value != null ||
                              rxFechaInicial.value != null,
                          onSelected: (value) {
                            if (!value) {
                              rxFechaFinal.value = null;
                              rxFechaInicial.value = null;
                              return;
                            }
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Fecha",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Aplicar"),
                                        )
                                      ],
                                    ),
                                    Text("Fecha inicial",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).hintColor)),
                                    OutlinedButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(
                                            () => Text(
                                                rxFechaInicial.value != null
                                                    ? formatDate.format(
                                                        rxFechaInicial.value!
                                                            .toDate())
                                                    : "Seleccionar fecha"),
                                          ),
                                          const Icon(Icons.date_range)
                                        ],
                                      ),
                                      onPressed: () async {
                                        final fechaInical =
                                            await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime.now(),
                                        );
                                        if (fechaInical != null) {
                                          rxFechaInicial.value =
                                              Timestamp.fromDate(
                                            fechaInical.add(
                                              const Duration(days: 1),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text("Fecha final",
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).hintColor)),
                                    OutlinedButton(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() => Text(rxFechaFinal.value !=
                                                  null
                                              ? formatDate.format(
                                                  rxFechaFinal.value!.toDate())
                                              : "Seleccionar fecha")),
                                          const Icon(Icons.date_range)
                                        ],
                                      ),
                                      onPressed: () async {
                                        final fechaFinal = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2021),
                                          lastDate: DateTime.now(),
                                        );
                                        if (fechaFinal != null) {
                                          rxFechaFinal.value =
                                              Timestamp.fromDate(
                                            fechaFinal,
                                          );
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    )
                  ],
                  pinned: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    snap.data!.docs.map(
                      (e) {
                        const boldtext = TextStyle(fontWeight: FontWeight.bold);
                        final items = <Widget>[
                          const Text(
                            "Productos:",
                            style: boldtext,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                        ];
                        double total = 0;
                        items.addAll(
                          e.data().detalles.map(
                            (d) {
                              total += d.precio;
                              return Text(
                                  "${d.cantidad} ${d.unidadMedida} ${d.producto.id} L.${d.precio}");
                            },
                          ),
                        );
                        items.addAll([
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Total: $total",
                            style: boldtext,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text("Cliente: ${e.data().cliente.id}"),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "Empleado: ${e.data().empleado.id}",
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Chip(
                            label: Text(
                              formatDateTime.format(
                                e.data().fecha.toDate(),
                              ),
                            ),
                          ),
                        ]);
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items,
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                )
              ],
            );
          })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/ventas_form");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
