import 'package:flutter/material.dart';

import '../model/catalogo_model.dart';
import '../utils/cache.dart' as cache;
import '../utils/personalizacion.dart' as prs;
import '../../preference/shared_preferences.dart';
import '../providers/catalogo_provider.dart';

class CatalogoCard extends StatelessWidget {
  CatalogoCard(
      {@required this.catalogoModel,
      @required this.onTab,
      @required this.isChatCajero,
      Key key})
      : super(key: key);

  final CatalogoModel catalogoModel;
  final bool isChatCajero;
  final Function onTab;
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final CatalogoProvider _catalogoProvider = CatalogoProvider();
  @override
  Widget build(BuildContext context) {
    return _card(context);
  }

  Widget _cardContenido() {
    return Column(
      children: <Widget>[
        _avatar(),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Center(
                child: Text(
              catalogoModel.agencia,
              style: TextStyle(color: Colors.blueGrey, fontSize: 12.0),
              textAlign: TextAlign.center,
            )),
          ),
        ),
      ],
    );
  }





Future<String> obtenerResultado() async {
  String idUrbe = _prefs.idUrbe;

  final response = await _catalogoProvider.controlador(idUrbe);
  final resultado = response.body;
  print(resultado);
  return resultado;
}


Widget _card(BuildContext context) {
  final card = Card(
    elevation: 1.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    child: _cardContenido(),
  );
  return Stack(
    children: <Widget>[
      card,
      if (catalogoModel.abiero != '' && _prefs.control == '0')
        sinRepartidores(context),
      if (catalogoModel.abiero == '') cerrado(context),
      etiqueta(context),
      Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.blueAccent.withOpacity(0.6),
            onTap: () {
              onTab(catalogoModel);
            },
          ),
        ),
      ),
      if (catalogoModel.abiero == '1' && _prefs.control != '0')
        Container(),
    ],
  );
}

  Widget etiqueta(BuildContext context) {
    if (catalogoModel.label == '') return Container();
    return Positioned(
      top: 15.0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: prs.colorButtonSecondary,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
                child: Text(catalogoModel.label,
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

Widget cerrado(BuildContext context) {
  return Positioned(
    top: 0.0,
    left: 0.0,
    right: 0.0,
    bottom: 0.0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            'Local Cerrado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              backgroundColor: Colors.transparent,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}



Widget sinRepartidores(BuildContext context) {
  return Positioned(
    top: 0.0,
    left: 0.0,
    right: 0.0,
    bottom: 0.0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: Colors.white,
          width: 4.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.white,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Container(
    width: 200,
    height: 37,
    color: Colors.white,
  ), 
),
              Text(
                'Sin repartidores Disponibles',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _avatar() {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: cache.fadeImage(catalogoModel.img,
          acronimo: catalogoModel.observacion),
    );
  }
}
