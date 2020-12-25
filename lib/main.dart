import 'package:flutter/material.dart';
import 'package:intent/action.dart' as acao;
import 'package:intent/extra.dart';
import 'package:intent/intent.dart' as tela;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String cliente, mac;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liberacao',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Liberação de Serviço'),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
                onPressed: () {
                  tela.Intent()
                    ..setAction(acao.Action.ACTION_SEND)
                    ..setType('text/plain')
                    ..putExtra(Extra.EXTRA_TEXT,
                        '*Nome:* ' + cliente + '\n*MAC:* ' + mac)
                    ..startActivity().catchError((e) => print(e));
                })
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) => cliente = value,
                decoration: InputDecoration(
                  labelText: 'Cód ou Nome',
                ),
              ),
              TextField(
                onChanged: (value) => mac = value,
                decoration: InputDecoration(
                  labelText: 'MAC',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Sinal',
                      ),
                    ),
                  ),
                ],
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sinal do Cliente',
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Referências',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
