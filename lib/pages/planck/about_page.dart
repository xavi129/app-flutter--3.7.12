import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/button.dart' as btn;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/utils.dart' as utils;

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  _AboutPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
        leading: utils.leading(context),
      ),
      body:
          Center(child: Container(child: _body(), width: prs.anchoFormulario)),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _contenido())),
        btn.confirmar('POWERED BY PLANCK', () {
          _launchURL('https://www.planck.biz/');
        }),
      ],
    );
  }

  Column _contenido() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 35.0),
              GestureDetector(
                onTap: () {
                  _source();
                },
                child: Image.asset("assets/icon_.png", height: 270),
              ),
              const Text(
                "This software is distributed under MIT license. It is available at UDEMY in the author's account. Juan Pablo Guamán Rodríguez (Planck)",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              btn.bootonIcon('Source code', Icon(Icons.download), _source),
              SizedBox(height: 20.0),
              btn.booton('Política de privacidad', _politicas),
              SizedBox(height: 20.0),
              btn.booton('Términos y condiciones', _terminos),
              SizedBox(height: 80.0),
            ],
          ),
        ),
      ],
    );
  }

  _source() {
    _launchURL('https://udemy.planck.biz/delivery');
  }

  _politicas() {
    _launchURL('https://www.planck.biz/politica-de-privacidad');
  }

  _terminos() {
    _launchURL('https://www.planck.biz/terminos-y-condiciones');
  }

  _launchURL(url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication))
      throw 'Could not launch $_url';
  }
}
