import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/login/componentes/barra_menu.dart';
import '../../modules/login/widgets/pagina_acessar.dart';
import '../../modules/login/widgets/pagina_config.dart';
import '../../modules/login/widgets/rodape_empresa.dart';
import '../../app_controller.dart';

class LoginPage extends StatefulWidget {
  final String title;
  const LoginPage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ModularState<LoginPage, AppController>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController _pageController;

  Color esquerda = Colors.black;
  Color direita = Colors.white;

  SharedPreferences arqIni;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ct = Modular.get<AppController>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  Color(0xff46997D),
                  Color(0xff317183),
                ],
                begin: const FractionalOffset(0.5, 0.0),
                end: const FractionalOffset(0.3, 1.0),
                tileMode: TileMode.clamp,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: BounceInDown(
                    child: FlutterLogo(
                      size: MediaQuery.of(context).size.height / 2.5,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: ElasticInLeft(
                    child: BarraMenu(
                      pageController: _pageController,
                      esquerda: esquerda,
                      direita: direita,
                    ),
                  ),
                ),
                Expanded(
                  child: ElasticInRight(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        if (i == 0) {
                          setState(() {
                            direita = Colors.white;
                            esquerda = Colors.black;
                          });
                        } else {
                          if (i == 1) {
                            setState(() {
                              direita = Colors.black;
                              esquerda = Colors.white;
                            });
                          }
                        }
                      },
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: PaginaAcessar(
                            userControler: ct.loginUsuarioController,
                            senhaControler: ct.loginSenhaController,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          //http://www.flutter-color-picker.site/
                          child: PaginaConfig(
                            ipControler: controller.configIpController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                BounceInUp(child: RodapeEmpresa()),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
