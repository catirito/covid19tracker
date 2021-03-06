import 'package:flutter/material.dart';
import './statusPanel.dart';



class WorldPanel extends StatelessWidget {
  final Map worldData;
  WorldPanel({Key key, this.worldData}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    
    return Container(
      child: GridView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 2),
        children: <Widget>[
          StatusPanel(
            title: 'TOTAL CONFIRMED',
            panelColor: Colors.red[100],
            textColor: Colors.red,
            count: worldData['cases'],
          ),
          StatusPanel(
            title: 'CURRENT ACTIVE',
            panelColor: Colors.blue[100],
            textColor: Colors.blue[900],
            count: worldData['active'],
          ),
          StatusPanel(
            title: 'TOTAL RECOVERED',
            panelColor: Colors.green[100],
            textColor: Colors.green,
            count: worldData['recovered'],
          ),
          StatusPanel(
            title: 'TOTAL DEATHS',
            panelColor: Colors.grey[400],
            textColor: Colors.grey[900],
            count: worldData['deaths'],
          ),

        ],
      ),
    );
  }
}
