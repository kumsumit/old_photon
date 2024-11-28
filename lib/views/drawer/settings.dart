import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photon/components/constants.dart';
import 'package:photon/db/fastdb.dart';
import 'package:photon/services/file_services.dart';
import 'package:photon/views/drawer/edit_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _future() async {
    return await FileMethods.getSaveDirectory();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
        builder: (_, AdaptiveThemeMode mode, __) {
          return Scaffold(
              backgroundColor: mode.isDark
                  ? const Color.fromARGB(255, 27, 32, 35)
                  : Colors.white,
              appBar: AppBar(
                backgroundColor: mode.isDark ? Colors.blueGrey.shade900 : null,
                title: const Text("Settings"),
                leading: BackButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                flexibleSpace:
                    mode.isLight ? Container(decoration: appBarGradient) : null,
              ),
              body: FutureBuilder(
                future: _future(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.done) {
                    return Center(
                      child: Container(
                        color: w > 720
                            ? mode.isDark
                                ? Colors.grey.shade900
                                : null
                            : null,
                        width: w > 720 ? w / 1.4 : w,
                        child: Center(
                          child: ListView(
                            children: [
                              ListTile(
                                title: const Text("Save path"),
                                subtitle: Text(snap.data.toString()),
                                trailing: IconButton(
                                  onPressed: () async {
                                    var resp = await FilePicker.platform
                                        .getDirectoryPath();
                                    setState(() {
                                      if (resp != null) {
                                        FileMethods.editDirectoryPath(resp);
                                      }
                                    });
                                  },
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    size: w > 720 ? 38 : 24,
                                    semanticLabel: 'Edit path',
                                  ),
                                ),
                              ),
                              ListTile(
                                title: const Text('Toggle theme'),
                                trailing: Switch(
                                  value: FastDB.getIsDarkTheme() == true,
                                  onChanged: (val) async{
                                    setState(() {
                                      if ( FastDB.getIsDarkTheme() == true) {
                                        AdaptiveTheme.of(context).setLight();
                                        FastDB.putIsDarkTheme(false);
                                      } else {
                                        AdaptiveTheme.of(context).setDark();
                                        FastDB.putIsDarkTheme(true);
                                      }
                                    });
                                    await FastDB.flush();
                                  },
                                ),
                              ),
                              ListTile(
                                trailing: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const EditProfilePage();
                                    }));
                                  },
                                  icon: SvgPicture.asset(
                                    'assets/icons/profile_edit.svg',
                                    colorFilter: ColorFilter.mode(  mode.isDark
                                        ? Colors.white
                                        : Colors.black, BlendMode.srcIn,),
                                    
                                  ),
                                ),
                                title: const Text('Edit profile'),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ));
        });
  }
}
