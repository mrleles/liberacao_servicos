import 'dart:io';

import 'package:share_extend/share_extend.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liberacao',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  File _image;
  final picker = ImagePicker();
  String cliente = '';
  String mac,
      cto,
      sinalCto,
      sinalCliente,
      referencias,
      cadastrar,
      pppoe,
      tv,
      provisionar,
      remoto,
      textoASerEnviado;
  String path = '';
  bool boxCadastrar = false;
  bool boxPPPOE = false;
  bool boxTV = false;
  bool boxProvisionar = false;
  bool boxRemoto = false;
  TextEditingController _controller,
      _controllerCto,
      _controllerSinalCto,
      _controllerRef;
  String selectedService = 'Instalação Fibra';
  PickedFile pickedFile;

  Future<void> readBarcode() async {
    mac = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.DEFAULT);
    print(mac);
    setState(() {
      _controller = TextEditingController(text: mac);
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cto', cto);
    await prefs.setString('sinalCto', sinalCto);
    await prefs.setString('referencias', referencias);
  }

  Future<void> readData() async {
    final prefs = await SharedPreferences.getInstance();
    cto = prefs.getString('cto');
    sinalCto = prefs.getString('sinalCto');
    referencias = prefs.getString('referencias');
    path = prefs.getString('path');
    _image = File(path);
    setState(() {
      _controllerCto = TextEditingController(text: cto);
      _controllerSinalCto = TextEditingController(text: sinalCto);
      _controllerRef = TextEditingController(text: referencias);
    });
  }

  Future<void> cleanData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cto', '');
    await prefs.setString('sinalCto', '');
    await prefs.setString('referencias', '');
    await prefs.setString('path', '');
    path = '';
    setState(() {
      _controllerCto = TextEditingController(text: '');
      _controllerSinalCto = TextEditingController(text: '');
      _controllerRef = TextEditingController(text: '');
    });
  }

  Future getImage() async {
    pickedFile = await picker.getImage(source: ImageSource.camera);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('path', pickedFile.path);
    path = pickedFile.path;
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Nenhuma foto tirada!');
      }
    });
  }

  // Future<void> setPath() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('path', '');
  // }

  Widget _decideImage() {
    if (path.isEmpty) {
      //setPath();
      return Expanded(
          child: Text(
        'Foto da anilha',
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ));
    } else {
      return Expanded(
        child: Image.file(_image),
      );
    }
  }

  void enviar(BuildContext context) {
    if (boxCadastrar) {
      cadastrar = '\nPrecisa cadastrar';
    } else {
      cadastrar = '';
    }
    if (boxPPPOE) {
      pppoe = '\nManda o PPPoE';
    } else {
      pppoe = '';
    }
    if (boxTV) {
      tv = '\nPossui TV';
    } else {
      tv = '';
    }
    if (boxProvisionar) {
      provisionar = '\nErro ao provisionar';
    } else {
      provisionar = '';
    }
    if (boxRemoto) {
      remoto = '\nAcesso remoto liberado';
    } else {
      remoto = '';
    }
    if (cliente.isEmpty != true) {
      if (path.isEmpty == false) {
        textoASerEnviado =
            'Liberar $selectedService:\nNome: $cliente\nMAC: $mac\nCTO: $cto $sinalCto\nSinal: $sinalCliente\nReferências: $referencias$cadastrar$pppoe$tv$provisionar$remoto';
        ShareExtend.share(path, 'image', extraText: textoASerEnviado);
      } else {
        final snackBar = SnackBar(
          content: Text('Favor tirar foto da anilha'),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(content: Text("Campos vazios!"));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liberação'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: () {
                  cleanData();
                  final snackBar = SnackBar(content: Text("Campos limpos!"));
                  Scaffold.of(context).showSnackBar(snackBar);
                },
              );
            },
          ),
          Builder(builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                saveData();
                final snackBar = SnackBar(content: Text("Campos salvos!"));
                Scaffold.of(context).showSnackBar(snackBar);
              },
            );
          }),
          Builder(builder: (BuildContext context) {
            return IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  enviar(context);
                });
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Serviço:   ',
                    textScaleFactor: 1.2,
                  ),
                  DropdownButton(
                      value: selectedService,
                      items: [
                        DropdownMenuItem(
                          child: Text('Instalação Fibra'),
                          value: 'Instalação Fibra',
                        ),
                        DropdownMenuItem(
                          child: Text('Instalação de TV'),
                          value: 'Instalação de TV',
                        ),
                        DropdownMenuItem(
                          child: Text('Instalação Rádio'),
                          value: 'Instalação Rádio',
                        ),
                        DropdownMenuItem(
                          child: Text('Migração para Fibra'),
                          value: 'Migração para Fibra',
                        ),
                        DropdownMenuItem(
                          child: Text('Manutenção'),
                          value: 'Manutenção',
                        ),
                        DropdownMenuItem(
                          child: Text('Mudança de Ponto'),
                          value: 'Mudança de Ponto',
                        ),
                        DropdownMenuItem(
                          child: Text('Transf. de Endereço'),
                          value: 'Transf. de Endereço',
                        ),
                        DropdownMenuItem(
                          child: Text('Troca de Fibra'),
                          value: 'Troca de Fibra',
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedService = value;
                        });
                      }),
                ],
              ),
              TextField(
                keyboardType: TextInputType.name,
                onChanged: (value) => cliente = value,
                decoration: InputDecoration(
                  labelText: 'Cód ou Nome',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) => mac = value,
                      decoration: InputDecoration(
                        labelText: 'MAC',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  RaisedButton(
                    onPressed: () => readBarcode(),
                    child: Text('Capturar MAC'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controllerCto,
                      onChanged: (value) => cto = value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'CTO',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controllerSinalCto,
                      onChanged: (value) => sinalCto = value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sinal',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => sinalCliente = value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sinal do Cliente',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controllerRef,
                      onChanged: (value) => referencias = value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Referências',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text('PON/REG apagado?'),
                      trailing: Checkbox(
                          value: boxCadastrar,
                          onChanged: (value) {
                            setState(() {
                              boxCadastrar = value;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text('Precisa do PPPoE?'),
                      trailing: Checkbox(
                          value: boxPPPOE,
                          onChanged: (value) {
                            setState(() {
                              boxPPPOE = value;
                            });
                          }),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text('Tem TV?'),
                      trailing: Checkbox(
                          value: boxTV,
                          onChanged: (value) {
                            setState(() {
                              boxTV = value;
                            });
                          }),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        'Provisionado?',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      trailing: Checkbox(
                          value: boxProvisionar,
                          onChanged: (value) {
                            setState(() {
                              boxProvisionar = value;
                            });
                          }),
                    ),
                  ),
                ],
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text('Liberou Acesso Remoto?'),
                trailing: Checkbox(
                    value: boxRemoto,
                    onChanged: (value) {
                      setState(() {
                        boxRemoto = value;
                      });
                    }),
              ),
              Row(
                children: [
                  _decideImage(),
                  Expanded(
                    child: FloatingActionButton(
                      mini: true,
                      onPressed: getImage,
                      tooltip: 'Tirar Foto',
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
