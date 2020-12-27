import 'dart:io';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:intent/action.dart' as acao;
// import 'package:intent/extra.dart';
// import 'package:intent/intent.dart' as tela;
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
  String cliente,
      mac,
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
    setState(() {
      _controllerCto = TextEditingController(text: cto);
      _controllerSinalCto = TextEditingController(text: sinalCto);
      _controllerRef = TextEditingController(text: referencias);
    });
  }

  Future getImage() async {
    pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Nenhuma imagem selecionada');
      }
    });
  }

  Future<void> _shareImage() async {
    try {
      final ByteData bytes = await rootBundle.load(pickedFile.path);
      await Share.file(
          'anilha', 'anilha.jpg', bytes.buffer.asUint8List(), 'image/jpg',
          text: textoASerEnviado);
    } catch (e) {
      print('Erro: $e');
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
          // IconButton(
          //   icon: Icon(
          //     Icons.list,
          //     color: Colors.white,
          //   ),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              saveData();
            },
          ),
          Builder(builder: (BuildContext context) {
            return IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
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
                  if (cliente != null) {
                    // tela.Intent()
                    //   ..setAction(acao.Action.ACTION_SEND)
                    //   ..setType('text/plain')
                    //   ..putExtra(Extra.EXTRA_TEXT,
                    //       'Liberar $selectedService:\nNome: $cliente\nMAC: $mac\nCTO: $cto $sinalCto\nSinal: $sinalCliente\nReferências: $referencias$cadastrar$pppoe$tv$provisionar$remoto')
                    //   ..startActivity().catchError((e) => print(e));
                    textoASerEnviado =
                        'Liberar $selectedService:\nNome: $cliente\nMAC: $mac\nCTO: $cto $sinalCto\nSinal: $sinalCliente\nReferências: $referencias$cadastrar$pppoe$tv$provisionar$remoto';
                    _shareImage();
                  } else {
                    final snackBar = SnackBar(content: Text("Campos vazios!"));
                    Scaffold.of(context).showSnackBar(snackBar);
                  }
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
                  FlatButton(
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
              ListTile(
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
              ListTile(
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
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text('Possui TV??'),
                trailing: Checkbox(
                    value: boxTV,
                    onChanged: (value) {
                      setState(() {
                        boxTV = value;
                      });
                    }),
              ),
              ListTile(
                visualDensity: VisualDensity.compact,
                title: Text('Problema ao Provisionar?'),
                trailing: Checkbox(
                    value: boxProvisionar,
                    onChanged: (value) {
                      setState(() {
                        boxProvisionar = value;
                      });
                    }),
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
              _image == null ? Text('Nenhuma foto tirada') : Image.file(_image),
              FloatingActionButton(
                mini: true,
                onPressed: getImage,
                tooltip: 'Tirar Foto',
                child: Icon(Icons.add_a_photo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
