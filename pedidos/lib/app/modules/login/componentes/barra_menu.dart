import 'package:flutter/material.dart';

import 'bolha_indicadora.dart';

class BarraMenu extends StatelessWidget {
  final PageController pageController;
  final Color esquerda;
  final Color direita;

  const BarraMenu(
      {Key key,
      @required this.pageController,
      this.esquerda = Colors.black,
      this.direita = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0xff317183),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      child: CustomPaint(
        painter: BolhaIndicadora(pageController: pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  pageController?.animateToPage(0,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
                child: Text(
                  'Acessar',
                  style: TextStyle(color: esquerda, fontSize: 16),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () {
                  pageController?.animateToPage(1,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                },
                child: Text(
                  'Config',
                  style: TextStyle(color: direita, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
