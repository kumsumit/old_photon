import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:photon/db/fastdb.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  List selected = List.generate(4, (index) => false);
  TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit your profile"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Select avatar by tapping',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: w > 720 ? w / 2.6 : w - 20,
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.2, crossAxisCount: 2),
                    itemBuilder: ((context, index) => Card(
                            child: GestureDetector(
                          onTap: () async{
                            setState(() {
                              selected.fillRange(0, 4, false);
                              selected[index] = true;
                            });
                             FastDB.putAvatarPath( 'assets/avatars/${index + 1}.png');
                            await FastDB.flush();
                          },
                          child: Card(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/avatars/${index + 1}.png'),
                                if (selected[index]) ...{
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: SvgPicture.asset(
                                      'assets/icons/right_mark.svg',
                                      colorFilter: ColorFilter.mode( const Color.fromARGB(
                                          255, 128, 242, 132), BlendMode.srcIn, ),
                                      width: 40,
                                    ),
                                  )
                                }
                              ],
                            ),
                          ),
                        ))),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: w > 720 ? w / 2.6 : w - 20,
                    child: TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                          hintText: 'Edit your username here'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async{
          if (usernameController.text.trim() != '') {
            FastDB.putUsername(usernameController.text.trim());
            await FastDB.flush();
          }
          if(context.mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
          }
        },
        label: const Text('Done'),
        icon: const Icon(Icons.done),
      ),
    );
  }
}
