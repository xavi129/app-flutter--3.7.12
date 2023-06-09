import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';

import './sistema.dart';
import './utils/permisos.dart' as permisos;
import './utils/personalizacion.dart' as prs;
import './utils/utils.dart' as utils;
import 'pages/admin/agencia_page.dart';
import 'pages/admin/compras_cajero_page.dart';
import 'pages/admin/sucursales_page.dart';
import 'pages/admin/ventas_page.dart';
import 'pages/delivery/carrito_page.dart';
import 'pages/delivery/catalogo_page.dart';
import 'pages/delivery/compras_cliente_page.dart';
import 'pages/delivery/compras_despacho_page.dart';
import 'pages/planck/about_page.dart';
import 'pages/planck/contacto_page.dart';
import 'pages/planck/contrasenia_page.dart';
import 'pages/planck/direcciones_page.dart';
import 'pages/planck/notificacion_page.dart';
import 'pages/planck/perfil_page.dart';
import 'pages/planck/preregistro_page.dart';
import 'pages/planck/puntos_page.dart';
import 'pages/planck/registrar_page.dart';
import 'pages/planck/sessiones_page.dart';
import 'Onboarding/onboarding_screen.dart';
import 'preference/intent_share.dart';
import 'preference/push_provider.dart';
import 'preference/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PreferenciasUsuario().init();
  final prefs = PreferenciasUsuario();
  await utils.getDeviceDetails();
  IntentShare().initIntentShare();
  PushProvider();
  if (prefs.idCliente == '' || prefs.idCliente == Sistema.ID_CLIENTE) {
    await permisos.ingresar();
  }
  try {
    prefs.simCountryCode = await FlutterSimCountryCode.simCountryCode;
  } catch (exception) {
    print('page: main.dart catch $exception');
    prefs.simCountryCode = 'MX';
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _prefs = PreferenciasUsuario();

  @override
  Widget build(BuildContext context) {
    String ruta = 'onboard';
    if (_prefs.auth == '') {
      ruta = 'principal';
    } else if (_prefs.clienteModel.perfil == '0') {
      ruta = 'catalogo';
    } else if (_prefs.clienteModel.perfil == '1') {
      ruta = 'compras_cajero';
    } else if (_prefs.clienteModel.perfil == '2') {
      ruta = 'compras_despacho';
    } else if (_prefs.clienteModel.perfil == '4') {
      ruta = 'onboard';
    } else {
      ruta = 'onboard';
    }
    print(Sistema.DOMINIO_GLOBAL);

    return MaterialApp(
      title: Sistema.aplicativoTitle,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('es', 'ES')],
      locale: Locale('es', 'ES'),
      initialRoute: ruta,
      debugShowCheckedModeBanner: Sistema.isTestMode,
      routes: {
        '': (BuildContext context) => CatalogoPage(),
        'principal': (BuildContext context) => RegistrarPage(),
        'registrar': (BuildContext context) => RegistrarPage(),
        'compras_cliente': (BuildContext context) => ComprasClientePage(),
        'direcciones_cliente': (BuildContext context) => DireccionesPage(),
        'carrito': (BuildContext context) => CarritoPage(),
        'compras_cajero': (BuildContext context) => ComprasCajeroPage(),
        'compras_despacho': (BuildContext context) => ComprasDespachoPage(),
        'contrasenia': (BuildContext context) => ContraseniaPage(),
        'perfil': (BuildContext context) => PerfilPage(),
        'contacto': (BuildContext context) => ContactoPage(),
        'puntos': (BuildContext context) => PuntosPage(),
        'sessiones': (BuildContext context) => SessionesPage(),
        'about': (BuildContext context) => AboutPage(),
        'sucursales': (BuildContext context) => SucursalesPage(),
        'catalogo': (BuildContext context) => CatalogoPage(isDeeplink: true),
        'preregistro': (BuildContext context) => PreRegistroPage(),
        'ventas': (BuildContext context) => VentasPage(),
        'agencia': (BuildContext context) => AngenciaPage(),
        'notificacion': (BuildContext context) => NotificacionPage(),
        'onboard': (BuildContext context) => OnboardingScreen(),
      },
      theme: ThemeData(
          primaryColor: prs.colorAppBar,
          iconTheme: IconThemeData(color: Colors.white), // Set the color of the drawer button to black
          appBarTheme: AppBarTheme(
              elevation: 0.7, centerTitle: true, color: prs.colorAppBar),),   
    );
  }
}
