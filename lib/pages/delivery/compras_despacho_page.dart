import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../bloc/compras_despacho_bloc.dart';
import '../../card/chat_despacho_card.dart';
import '../../card/shimmer_card.dart';
import '../../model/cajero_model.dart';
import '../../model/chat_despacho_model.dart';
import '../../model/despacho_model.dart';
import '../../preference/push_provider.dart';
import '../../preference/shared_preferences.dart';
import '../../providers/cliente_provider.dart';
import '../../providers/despacho_provider.dart';
import '../../utils/conexion.dart';
import '../../utils/conf.dart' as conf;
import '../../utils/dialog.dart' as dlg;
import '../../utils/permisos.dart' as permisos;
import '../../utils/personalizacion.dart' as prs;
import '../../utils/rastreo.dart';
import '../../utils/utils.dart' as utils;
import '../../widgets/en_linea_widget.dart';
import '../../widgets/menu_widget.dart';
import 'calificaciondespacho_page.dart';
import 'despacho_page.dart';
import '../../bloc/direccion_bloc.dart';

//INIT MOTORIZADO
class ComprasDespachoPage extends StatefulWidget {
  @override
  _ComprasDespachoPageState createState() => _ComprasDespachoPageState();
}

class _ComprasDespachoPageState extends State<ComprasDespachoPage>
    with WidgetsBindingObserver {
  final ClienteProvider _clienteProvider = ClienteProvider();
  final ComprasDespachoBloc _comprasDespachoBloc = ComprasDespachoBloc();
  final DespachoProvider _despachoProvider = DespachoProvider();
  final PreferenciasUsuario _prefs = PreferenciasUsuario();
  final PushProvider _pushProvider = PushProvider();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DireccionBloc _direccionBloc = DireccionBloc();
  bool _direccion = false;
  bool _saving = false;
  StreamController<bool> _cambios = StreamController<bool>.broadcast();
  Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _typeControllerDireccion =
      TextEditingController();

  void disposeStreams() {
    _cambios?.close();
    super.dispose();
  }
  

  void enviarsq() {
  String idUrbe = '1'; // Aquí puedes cambiar el valor de idUrbe si lo necesitas
  _clienteProvider.urbe(idUrbe);
   _prefs.idUrbe = idUrbe;
  
 }

  void enviarvg() {
  String idUrbe = '2'; // Aquí puedes cambiar el valor de idUrbe si lo necesitas
    _clienteProvider.urbe(idUrbe);
    _prefs.idUrbe = idUrbe;
   
 }

  bool _init = false;

funcion2 (){

  _typeControllerDireccion.text = '0';
}
  @override
  void initState() {
    _cambios.stream.listen((internet) {
      if (!mounted) return;
      if (internet && _init) {
        _comprasDespachoBloc.listarCompras(
            _selectedIndex, _dateTime.toString());
      }
      _init = true;
    });

    Conexion();
    WidgetsBinding.instance.addObserver(this);
    _comprasDespachoBloc.listarCompras(_selectedIndex, _dateTime.toString());
    super.initState();

    _pushProvider.context = context;
    _pushProvider.chatsDespacho.listen((ChatDespachoModel chatDespachoModel) {
      if (!mounted) return;
      _comprasDespachoBloc.actualizarCompras(
          chatDespachoModel, _selectedIndex, _dateTime.toString());
    });

    _pushProvider.objects.listen((Object despacho) {
      if (!mounted) return;
      _comprasDespachoBloc.nuevo(despacho);
    });

    _clienteProvider.actualizarToken().then((isActualizo) {
      permisos.verificarSession(context);
    });

    _pushProvider.cancelAll();

    if (_prefs.rastrear) Rastreo().start(context, isRadar: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        permisos.verificarSession(context);
        if (_prefs.rastrear) Rastreo().start(context, isRadar: false);
        _comprasDespachoBloc.listarCompras(
            _selectedIndex, _dateTime.toString());
        _pushProvider.cancelAll();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      default:
        break;
    }
  }

  String title = 'Solicitudes';

  Widget _rastrear() {
    return _prefs.rastrear
        ? Container(
            color: Colors.green,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.peopleCarry,
                  size: 26.0, color: Colors.white),
              onPressed: () {
                accionSwitch(false);
              },
            ),
          )
        : Container(
            color: Colors.red,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.bed, size: 26.0, color: Colors.white),
              onPressed: () {
                accionSwitch(true);
              },
            ),
          );
  }

  accionSwitch(bool state) async {
    if (state) {
      _saving = true;
      if (mounted) setState(() {});
      await Rastreo().start(context);
      _saving = false;
      if (mounted) setState(() {});
    } else {
      _saving = true;
      if (mounted) setState(() {});
      await Rastreo().stop();
      _saving = false;
      if (mounted) setState(() {});
    }
  }

_mostrarDirecciones() async {
  FocusScope.of(context).requestFocus(FocusNode());
  utils.mostrarProgress(context, barrierDismissible: false);
  await _direccionBloc.listar();
  Navigator.pop(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
        title: Text('Selecciona una opción'),
        actions: [
          TextButton(
            child: Text('Recibir de SQ', style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              enviarsq();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Recibir de VG', style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {
              enviarvg();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  _direccion = !_direccion;
}
  @override
  Widget build(BuildContext context) {
    if (_prefs.clienteModel.perfil == '0')
      return Container(child: Center(child: Text('Cliente no autorizado')));

    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuWidget(),
      appBar: AppBar(
        title: Container(
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    'Area de entrega ${_prefs.idUrbe == '1' ? "SQ" : "VG"}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  width: 150.0,
                ),
              ],
            ),
            onPressed: _mostrarDirecciones,
          ),
        ),
        actions: <Widget>[_rastrear()],
      ),
      body: ModalProgressHUD(
        color: Colors.black,
        opacity: 0.4,
        progressIndicator: utils.progressIndicator('Procesando...'),
        inAsyncCall: _saving,
        child: Column(
          children: <Widget>[
            EnLineaWidget(cambios: _cambios),
            _crearFecha(context),
            Expanded(child: _listaCar(context))
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.peopleCarry), label: 'Solicitudes'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.list), label: 'Historial'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: prs.colorButtonSecondary,
        onTap: _onItemTapped,
      ),
    );
  }

  int _selectedIndex = 0;
  DateTime _dateTime = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  void _onItemTapped(int index) {
    _dateTime = DateTime.now();
    _selectedIndex = index;
    if (index == 0)
      title = 'Solicitudes';
    else
      title = 'Historial';
    _onRefresh();
  }

  Widget _crearFecha(BuildContext context) {
    return Visibility(
      visible: _selectedIndex == 1,
      child: TableCalendar(
        calendarFormat: CalendarFormat.week,
        firstDay: DateTime.utc(2019, 1, 1),
        lastDay: DateTime.utc(2069, 1, 1),
        focusedDay: _focusedDay,
        locale: 'es',
        onDaySelected: (selectedDay, focusedDay) {
          _dateTime = selectedDay;
          _focusedDay = focusedDay;
          _onRefresh();
        },
      ),
    );
  }

  Widget _listaCar(context) {
    return StreamBuilder(
      stream: _comprasDespachoBloc.comprasStream,
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0)
            return createListView(context, snapshot);
          return Container(
            width: double.infinity,
            height: double.infinity,
            child: !_prefs.rastrear && _selectedIndex == 0 ? _contenido() : Center( child: Image(
                  width: 300.0,
                  image: AssetImage(
                       'assets/icon_.png'), // anadir gif proximanete de repartidor
                  fit: BoxFit.cover),),
            );
        } else {
          return ShimmerCard();
        }
      },
    );
  }


  Container _contenido() {
    return Container(
      child: Stack(
        children: <Widget>[
          GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(30.64701, -115.9693),
                  zoom: 11,
                ),
               mapType: MapType.normal,
                polygons: {
                  Polygon(
                    polygonId: PolygonId('polygon1'),
                    points: [
                      LatLng(30.508091, -115.903961),
                      LatLng(30.5927626, -115.9386794),
                      LatLng(30.590439, -115.9511074),
                      LatLng(30.5864568, -115.9671044),
                      LatLng(30.582909, -115.982097),
                      LatLng(30.515627, -115.961725),
                      LatLng(30.5105311, -115.9445301),
                      LatLng(30.501588, -115.929655),
                      LatLng(30.502668, -115.922264),
                      LatLng(30.508091, -115.903961),
                    ],
                    fillColor: Colors.blueAccent.withOpacity(0.1),
                    strokeColor: Colors.green,
                    strokeWidth: 5,
                  ),
                  Polygon(
                    polygonId: PolygonId('polygon2'),
                    points: [
                      LatLng(30.6903999, -115.9858991),
                      LatLng(30.701029, -115.9715371),
                      LatLng(30.705128, -115.9625336),
                      LatLng(30.7394056, -115.9707798),
                      LatLng(30.7752671, -115.9925131),
                      LatLng(30.7804741, -115.9935147),
                      LatLng(30.7843906, -115.9975204),
                      LatLng(30.7824581, -116.0095609),
                      LatLng(30.7790079, -116.0196902),
                      LatLng(30.768911, -116.0299614),
                      LatLng(30.6887733, -116.0068872),
                      LatLng(30.6903999, -115.9858991),
                    ],
                    fillColor: Colors.blueAccent.withOpacity(0.1),
                    strokeColor: Colors.green,
                    strokeWidth: 5,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
              ),
              ],
      ),
    );
  }

  Future _onRefresh() async {
    _saving = true;
    if (mounted) setState(() {});
    await _comprasDespachoBloc.listarCompras(
        _selectedIndex, _dateTime.toString());
    _saving = false;
    if (mounted) setState(() {});
    return;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    return RefreshIndicator(
      onRefresh: () => _comprasDespachoBloc.listarCompras(
          _selectedIndex, _dateTime.toString()),
      child: ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          return ChatDespachoCard(
              despachoModel: snapshot.data[index],
              onTab: _onTab,
              enviarPostular: _enviarPostular,
              isChatDespacho: true);
        },
      ),
    );
  }

  _onTab(DespachoModel despachoModel) async {
    if (despachoModel.idDespachoEstado > 1) {
      _iraDespacho(despachoModel);
    } else {
      utils.mostrarSnackBar(context, 'Desliza para postular ->',
          milliseconds: 2000);
    }
  }

  _enviarPostular(DespachoModel despachoModel) async {
    if (despachoModel.idDespachoEstado > 1) {
      _iraDespacho(despachoModel);
    } else {
      _saving = true;
      if (mounted) setState(() {});
      Rastreo().notificarUbicacion();
      await _despachoProvider.iniciar(despachoModel,
          (estado, error, DespachoModel despacho) {
        _saving = false;
        if (mounted) setState(() {});
        if (estado == 0) {
          _comprasDespachoBloc.eliminar(despachoModel);
          return dlg.mostrar(context, error);
        }
        despachoModel = despacho;
        _comprasDespachoBloc.actualizarPorDespacho(despacho);
        _iraDespacho(despacho);
      });
    }
  }

  _iraDespacho(DespachoModel despacho) {
    if (despacho.calificarConductor == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CalificaciondespachoPage(despachoModel: despacho),
        ),
      );
    } else {
      CajeroModel _cajero = new CajeroModel(
          estado: 'Confirmado',
          idDespacho: despacho.idDespacho,
          nombres: despacho.nombres,
          detalle: despacho.detalleJson,
          referencia: despacho.referenciaJson,
          costo: despacho.costo,
          costoEnvio: despacho.costoEnvio,
          sucursal: despacho.sucursalJson);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DespachoPage(conf.TIPO_CONDCUTOR,
              cajeroModel: _cajero, despachoModel: despacho),
        ),
      );
    }
    _saving = false;
  }
}
