import 'package:flutter/material.dart';

import '../bloc/catalogo_bloc.dart';
import '../bloc/promocion_bloc.dart';
import '../dialog/productos_dialog.dart';
import '../model/promocion_model.dart';
import '../preference/db_provider.dart';
import '../utils/cache.dart' as cache;
import '../utils/dialog.dart' as dlg;
import '../utils/personalizacion.dart' as prs;
import '../utils/utils.dart' as utils;
import '../../preference/shared_preferences.dart';

class ComprarPromoWidget extends StatefulWidget {
  final ScrollController pageController;
  final List<PromocionModel> promociones;
  final bool isOppen;
  final String agencia;

  ComprarPromoWidget(this.pageController,
      {@required this.promociones, this.isOppen = true, this.agencia = ''});

  @override
  _ComprarPromoWidgetState createState() => _ComprarPromoWidgetState();
}

class _ComprarPromoWidgetState extends State<ComprarPromoWidget> {
  final PromocionBloc _promocionBloc = PromocionBloc();
  final CatalogoBloc _catalogoBloc = CatalogoBloc();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  bool _inicio = true;
  bool _final = false;
 PromocionModel promocionModel  = PromocionModel();
  @override
  Widget build(BuildContext context) {
    bool _auxFinal = false;
    bool _auxInicio = true;
    widget.pageController.addListener(() {
      _auxFinal = widget.pageController.position.pixels >=
          widget.pageController.position.maxScrollExtent - 50;
      if (_auxFinal != _final) {
        _final = _auxFinal;
        if (mounted) if (mounted) setState(() {});
      }

      _auxInicio = widget.pageController.position.pixels <= 10;
      if (_auxInicio != _inicio) {
        _inicio = _auxInicio;
        if (mounted) if (mounted) setState(() {});
      }
    });
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(right: 0.0, left: 5.0),
          height: 150.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: widget.pageController,
            itemCount: widget.promociones.length,
            itemBuilder: (context, i) =>
                _tarjeta(context, widget.promociones[i]),
          ),
        ),
        utils.bandaIzquierda(_inicio, widget.pageController),
        utils.bandaDerecha(_final, widget.pageController),
      ],
    );
  }

  Widget _tarjeta(BuildContext context, PromocionModel promocion) {
    final tarjeta = Card(
        elevation: 0.2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          width: 330.0,
          child: Stack(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: _contenidoLista(promocion, context)),
              promocion.isComprada
                  ? utils.modalAgregadoAlCarrito()
                  : Container()
            ],
          ),
        ));

    return Stack(
      children: <Widget>[
        tarjeta,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blueAccent.withOpacity(0.6),
              onTap: () async {
                if (!widget.isOppen) {
                  return dlg.mostrar(
                    context,
                    widget.agencia,
                    titulo: 'Local cerrado',
                  );
                }

                if (promocion.estado <= 0) {
                  return dlg.mostrar(context, promocion.mensaje);
                }
                
               if (_prefs.control == '0' &&
                    promocion.estado == 1 ) {
                 return dlg.mostrar(context, 'Sin repartidores disponibles en este momento');
                }


                if (promocion.productos != null &&
                    promocion.productos.lP != null &&
                    promocion.productos.lP.length > 0) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ProductosDialog(promocion: promocion);
                      });
                  return;
                } else {
                  promocion.isComprada = !promocion.isComprada;
                  _promocionBloc.actualizar(promocion);
                  if (promocion.isComprada) {
                    await DBProvider.db.agregarPromocion(promocion);
                  } else {
                    await DBProvider.db.eliminarPromocion(promocion);
                  }
                  _catalogoBloc.actualizar(promocion);
                  _promocionBloc.carrito();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _contenidoLista(PromocionModel promocion, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: <Widget>[
            Container(
              width: 142.0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10.0),
                    topLeft: Radius.circular(10.0)),
                child: cache.fadeImage(promocion.imagen),
              ),
            ),
            etiqueta(context, promocion),
            if (promocion.estado == 0) cerrado(context, promocion),
            if (promocion.estado >= 1 && _prefs.control == '0') sinrep(context, promocion),
          ],
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 2.0, right: 5.0, top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(promocion.producto,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                SizedBox(height: 5.0),
                Text(promocion.descripcion,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.visible,
                    maxLines: 5,
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                SizedBox(height: 5.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: Container()),
                    prs.iconoDinero,
                    Text(promocion.precio.toStringAsFixed(2),
                        style:
                            TextStyle(fontSize: 17.0, color: prs.colorIcons)),
                    SizedBox(width: 5.0),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

  Widget sinrep(BuildContext context, PromocionModel promocion) {
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
          width: 1.0,
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
                'Sin repartidores disponibles',
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



Widget etiqueta(BuildContext context, PromocionModel promocionModel) {
  return Positioned(
    bottom: 10.0,
    left: 0,
    child: Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: prs.colorButtonSecondary,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              child: Text(promocionModel.incentivo,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}




Widget cerrado(BuildContext context, PromocionModel promocion) {
  return Positioned(
    top: 0.0,
    left: 0.0,
    right: 0.0,
    bottom: 0.0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 200,
                  height: 37,
                  color: Colors.transparent,
                ),
              ),
              Text(
                promocion.mensaje,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  backgroundColor: Colors.transparent,
                  fontWeight: FontWeight.bold,
                   // Establece la alineación del texto en el centro
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