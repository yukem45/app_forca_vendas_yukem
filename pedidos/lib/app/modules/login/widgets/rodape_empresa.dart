import 'package:flutter/material.dart';

class RodapeEmpresa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white10,
                  Colors.white,
                ],
                begin: const FractionalOffset(0, 0),
                end: const FractionalOffset(1, 1),
                stops: [0, 1],
                tileMode: TileMode.clamp,
              ),
            ),
            width: 100,
            height: 2,
          ),
          SizedBox(width: 5),
          Text(
            'COMTecnologia',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white10,
                ],
                begin: const FractionalOffset(0, 0),
                end: const FractionalOffset(1, 1),
                stops: [0, 1],
                tileMode: TileMode.clamp,
              ),
            ),
            width: 100,
            height: 2,
          ),
        ],
      ),
    );
  }
}
