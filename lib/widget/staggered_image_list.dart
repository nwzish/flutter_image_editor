// import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class StaggeredImageList extends StatelessWidget {
  final List<File> imageFiles;

  const StaggeredImageList({
    Key key,
    @required this.imageFiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StaggeredGridView.countBuilder(
    crossAxisCount: 2,
    itemCount: imageFiles.length,
    itemBuilder: (context,index) => ImageCard(
      imageData: imageFiles[index].path,

    ),
    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
    mainAxisSpacing: 8.0,
    crossAxisSpacing: 8.0,
  );

  // Widget ImageCard(imageData){
  //
  //   final String path = imageData.path;
  //
  //
  //
  //   return Card(
  //     clipBehavior: Clip.antiAlias,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(24),
  //     ),
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         Ink.image(
  //           image: FileImage(File(path)),
  //           child: InkWell(
  //             onTap: () {},
  //           ),
  //           // height: 240,
  //           fit: BoxFit.cover,
  //         ),
  //
  //       ],
  //     ),
  //   );


  // }
}


//
// class ImageCard extends StatelessWidget {
//   const ImageCard({this.imageData});
//
//   final String imageData;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       // clipBehavior: Clip.antiAlias,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Ink.image(
//             image: FileImage(File(imageData)),
//             child: InkWell(
//               onTap: () {},
//             ),
//             // height: 100,
//             fit: BoxFit.cover,
//           ),
//
//         ],
//       ),
//     );
//   }
// }
class ImageCard extends StatelessWidget {
  const ImageCard({this.imageData});

  final String imageData;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print(imageData);
        },
        child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.file(File(imageData),fit: BoxFit.cover),
      )
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({this.gridImage});

  final String gridImage;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: const Color(0x00000000),
      elevation: 3.0,
      child: new GestureDetector(
        onTap: () {
          print("hello");
        },
        child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new FileImage(File(gridImage)),
                fit: BoxFit.cover,
              ),
              borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
            )
        ),
      ),
    );
  }
}