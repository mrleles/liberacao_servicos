import 'package:flutter/material.dart';
import 'package:intent/action.dart' as acao;
import 'package:intent/extra.dart';
import 'package:intent/intent.dart' as tela;
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
      remoto;
  bool boxCadastrar = false;
  bool boxPPPOE = false;
  bool boxTV = false;
  bool boxProvisionar = false;
  bool boxRemoto = false;
  TextEditingController _controller;

  Future<void> readBarcode() async {
    mac = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.DEFAULT);
    print(mac);
    setState(() {
      _controller = TextEditingController(text: mac);
    });
  }

  // Future<void> saveData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.setString('cto', cto);
  //   prefs.setString('sinalCto', sinalCto);
  //   prefs.setString('referencias', referencias);
  //   print('Data saved: $cto, $sinalCto, $referencias');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liberação'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.list,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {},
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
                    tela.Intent()
                      ..setAction(acao.Action.ACTION_SEND)
                      ..setType('text/plain')
                      ..putExtra(Extra.EXTRA_TEXT,
                          'Liberar:\nNome: $cliente\nMAC: $mac\nCTO: $cto $sinalCto\nSinal: $sinalCliente\nReferências: $referencias$cadastrar$pppoe$tv$provisionar$remoto')
                      ..startActivity().catchError((e) => print(e));
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
                      onChanged: (value) => sinalCto = value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sinal',
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                onChanged: (value) => sinalCliente = value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sinal do Cliente',
                ),
              ),
              TextField(
                onChanged: (value) => referencias = value,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Referências',
                ),
              ),
              ListTile(
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
                title: Text('Liberou Acesso Remoto?'),
                trailing: Checkbox(
                    value: boxRemoto,
                    onChanged: (value) {
                      setState(() {
                        boxRemoto = value;
                      });
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
