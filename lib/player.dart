import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:music_player/play.dart';
import 'package:music_player/sec.dart';
import 'package:music_player/albumart.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:path_provider/path_provider.dart';
import './slider_thumb.dart';
import './slider_track.dart';
import './gradientmenu.dart';
import './audioplayerdata.dart';

// * Main PlayerPage Stateful Widget
class PlayerPage extends StatefulWidget {
  bool isLiked;
  String shuffleMode;
  String repeatMode;
  var likeSnackBar;
  var dislikeSnackBar;
  String platformVersion;
  bool isPlaying;
  Duration duration;
  Duration position;
  double slider;
  double sliderVolume;
  String error;
  num curIndex;
  PlayMode playMode;
  var list;
  PlayerPage({
    Key key,
    this.title,
    this.isLiked,
    this.shuffleMode,
    this.repeatMode,
    this.likeSnackBar,
    this.dislikeSnackBar,
    this.platformVersion,
    this.isPlaying,
    this.duration,
    this.slider,
    this.sliderVolume,
    this.error,
    this.curIndex,
    this.playMode,
    this.list,
  }) : super(key: key);

  final String title;

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

// * PlayerPage Initial State
class _PlayerPageState extends State<PlayerPage> {
  var openMenu = false;
  DragStartDetails startHorizontalDragDetails;
  DragUpdateDetails updateHorizontalDragDetails;

  final FlareControls flareControls = FlareControls();
  final FlareControls flareControls2 = FlareControls();
  final FlareControls flareControls3 = FlareControls();
  final FlareControls flareControls4 = FlareControls();
  final FlareControls flareControls5 = FlareControls();

  @override
  void initState() {
    super.initState();

    initPlatformState();
    setupAudio();
    // loadFile();
  }

  // @override
  // void dispose() {
  //   AudioManager.instance.stop();
  //   super.dispose();
  // }

  void setupAudio() {
    List<AudioInfo> _list = [];
    widget.list.forEach(
      (item) => _list.add(
        AudioInfo(item["url"],
            title: item["title"],
            desc: item["desc"],
            coverUrl: item["coverUrl"]),
      ),
    );

    AudioManager.instance.audioList = _list;
    AudioManager.instance.intercepter = true;
    AudioManager.instance.play(auto: false);

    AudioManager.instance.onEvents((events, args) {
      print("$events, $args");
      switch (events) {
        case AudioManagerEvents.start:
          print("start load data callback");
          widget.position = AudioManager.instance.position;
          widget.duration = AudioManager.instance.duration;
          widget.slider = 0;
          setState(() {});
          break;
        case AudioManagerEvents.ready:
          print("ready to play");
          widget.error = null;
          widget.sliderVolume = AudioManager.instance.volume;
          widget.position = AudioManager.instance.position;
          widget.duration = AudioManager.instance.duration;
          setState(() {});
          AudioManager.instance.seekTo(Duration(microseconds: 10));
          break;
        case AudioManagerEvents.seekComplete:
          widget.position = AudioManager.instance.position;
          widget.slider =
              widget.position.inMilliseconds / widget.duration.inMilliseconds;
          setState(() {});
          print("seek event is completed. position is [$args]/ms");
          break;
        case AudioManagerEvents.buffering:
          print("buffering $args");
          break;
        case AudioManagerEvents.playstatus:
          widget.isPlaying = AudioManager.instance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          widget.position = AudioManager.instance.position;
          widget.slider =
              widget.position.inMilliseconds / widget.duration.inMilliseconds;
          setState(() {});
          AudioManager.instance.updateLrc(args["position"].toString());
          break;
        case AudioManagerEvents.error:
          widget.error = args;
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          AudioManager.instance.next();
          break;
        case AudioManagerEvents.volumeChange:
          widget.sliderVolume = AudioManager.instance.volume;
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  void loadFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    // Please make sure the `test.mp3` exists in the document directory
    final file = File("${appDocDir.path}/test.mp3");
    AudioInfo info = AudioInfo("file://${file.path}",
        title: "file",
        desc: "local file",
        coverUrl: "https://homepages.cae.wisc.edu/~ece533/images/baboon.png");

    widget.list.add(info.toJson());
    AudioManager.instance.audioList.add(info);
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await AudioManager.instance.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      widget.platformVersion = platformVersion;
    });
  }

  void handleMenu() {
    this.setState(() {
      openMenu = openMenu ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            // * Root Container
            decoration: BoxDecoration(
              // * Background Gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(247, 51, 57, 62),
                  Color.fromARGB(255, 28, 30, 34)
                ],
              ),
            ),
            // * Main SafeArea
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  Center(
                    // * Main Column which contains all UI elements
                    child: Column(
                      children: <Widget>[
                        // * This column contains five expanded widgets
                        // * which all contain row widgets
                        Expanded(
                          // * 1st row
                          flex: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                // * Back Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: 18,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height:
                                            70, // TODO fix button size over different screen sizes
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "back",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // * Empty Container
                                width: constraints.maxWidth * 0.121,
                              ),
                              Container(
                                  // * 'PLAYING NOW' Text
                                  child: Text(
                                'PLAYING NOW',
                                style: TextStyle(
                                  fontFamily: 'Gotham',
                                  color: Color.fromARGB(255, 117, 119, 122),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              )),
                              Container(
                                // * Empty Container
                                width: constraints.maxWidth * 0.121,
                              ),
                              Container(
                                // * Settings Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "settings",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                            handleMenu();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // * 2nd row
                          flex: 25,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                  // * Album Art
                                  width: constraints.maxWidth * 0.85,
                                  height: constraints.maxWidth * 0.85,
                                  child: AlbumArt(),
                                ),
                                SizedBox(
                                  // // TODO fix height and width of the image to scale
                                  height: constraints.maxWidth * 0.8,
                                  width: constraints.maxWidth * 0.8,
                                  // // TODO fix this padding to work with diff screen sizes
                                  child: CircleAvatar(
                                    // * Album Art Image
                                    backgroundColor:
                                        Color.fromARGB(51, 20, 20, 20),
                                    backgroundImage: AssetImage(
                                        AudioManager.instance.info.coverUrl),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/animations/like.flr',
                                    controller: flareControls,
                                    animation: 'idle',
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/animations/next.flr',
                                    controller: flareControls2,
                                    animation: 'idle',
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/animations/prev.flr',
                                    controller: flareControls3,
                                    animation: 'idle',
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/animations/play.flr',
                                    controller: flareControls4,
                                    animation: 'idle',
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: FlareActor(
                                    'assets/animations/pause.flr',
                                    controller: flareControls5,
                                    animation: 'idle',
                                  ),
                                ),
                                ClipOval(
                                  child: GestureDetector(
                                    onTap: () async {
                                      bool playing = await AudioManager.instance
                                          .playOrPause();
                                      print("await -- $playing");
                                      playing
                                          ? flareControls4.play("play")
                                          : flareControls5.play("pause");
                                    },
                                    onDoubleTap: () {
                                      setState(() {
                                        widget.isLiked = !widget.isLiked;
                                      });
                                      print(widget.isLiked);
                                      flareControls.play("like");
                                      widget.isLiked
                                          ? Scaffold.of(context).showSnackBar(
                                              widget.dislikeSnackBar)
                                          : Scaffold.of(context).showSnackBar(
                                              widget.likeSnackBar);
                                    },
                                    onHorizontalDragStart: (dragDetails) {
                                      startHorizontalDragDetails = dragDetails;
                                    },
                                    onHorizontalDragUpdate: (dragDetails) {
                                      updateHorizontalDragDetails = dragDetails;
                                    },
                                    onHorizontalDragEnd: (endDetails) {
                                      double dx = updateHorizontalDragDetails
                                              .globalPosition.dx -
                                          startHorizontalDragDetails
                                              .globalPosition.dx;
                                      double dy = updateHorizontalDragDetails
                                              .globalPosition.dy -
                                          startHorizontalDragDetails
                                              .globalPosition.dy;
                                      double velocity =
                                          endDetails.primaryVelocity;

                                      //Convert values to be positive
                                      if (dx < 0) dx = -dx;
                                      if (dy < 0) dy = -dy;

                                      if (velocity < 0) {
                                        AudioManager.instance.next();
                                        flareControls2.play("next");
                                        print("Next");
                                      } else {
                                        AudioManager.instance.previous();
                                        flareControls3.play("prev");
                                        print("Prev");
                                      }
                                    },
                                    child: SizedBox(
                                      width: constraints.maxWidth * 0.8,
                                      height: constraints.maxWidth * 0.8,
                                      child: Text(''),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          // * 3rd row
                          flex: 7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              // * Song Name and Artist Name
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Text(''),
                                  Text(
                                    AudioManager.instance.info.title,
                                    style: TextStyle(
                                      fontFamily: 'Gotham',
                                      color: Color.fromARGB(255, 167, 168, 170),
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    AudioManager.instance.info.desc,
                                    style: TextStyle(
                                      fontFamily: 'Gotham',
                                      color: Color.fromARGB(255, 117, 119, 122),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(''),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // * 4th row
                          flex: 7, // FIXME fix seekbar widget thumb
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                width: constraints.maxWidth * 0.9,
                                child:
                                    songProgress(context, constraints.maxWidth),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          // * 5th row
                          flex: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                // * Repeat Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: Icon(
                                        widget.repeatMode != 'one'
                                            ? Icons.repeat
                                            : Icons.repeat_one,
                                        size: 18,
                                        color: widget.repeatMode != 'off'
                                            ? Colors.deepOrange[400]
                                            : Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "repeat",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                            setState(() {
                                              widget.repeatMode == 'on'
                                                  ? widget.repeatMode = 'one'
                                                  : widget.repeatMode == 'one'
                                                      ? widget.repeatMode =
                                                          'off'
                                                      : widget.repeatMode =
                                                          'on';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // * Backward Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.backward,
                                        size: 18,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "backward",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                            AudioManager.instance.previous();

                                            flareControls3.play("prev");
                                            print("Prev");
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // * Play/Pause Button
                                width: constraints.maxWidth * 0.194,
                                child: Stack(
                                  children: <Widget>[
                                    PlayPause(),
                                    Center(
                                      child: FaIcon(
                                        widget.isPlaying
                                            ? FontAwesomeIcons.pause
                                            : FontAwesomeIcons.play,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 90,
                                        width: 90,
                                        child: FloatingActionButton(
                                          heroTag: "playPause",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () async {
                                            bool playing = await AudioManager
                                                .instance
                                                .playOrPause();
                                            print("await -- $playing");
                                            HapticFeedback.vibrate();
                                            playing
                                                ? flareControls4.play("play")
                                                : flareControls5.play("pause");
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // * Forward Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.forward,
                                        size: 18,
                                        color: Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "forward",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                            AudioManager.instance.next();
                                            flareControls2.play("next");
                                            print("Next");
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                // * Shuffle Button
                                width: constraints.maxWidth * 0.121,
                                child: Stack(
                                  children: <Widget>[
                                    SecButton(),
                                    Center(
                                      child: Icon(
                                        Icons.shuffle,
                                        size: 18,
                                        color: widget.shuffleMode == 'on'
                                            ? Colors.deepOrange[400]
                                            : Colors.white38,
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        child: FloatingActionButton(
                                          heroTag: "shuffle",
                                          foregroundColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          splashColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          focusColor:
                                              Color.fromARGB(50, 0, 0, 0),
                                          elevation: 0,
                                          hoverElevation: 0,
                                          hoverColor: Colors.transparent,
                                          highlightElevation: 0,
                                          disabledElevation: 0,
                                          onPressed: () {
                                            HapticFeedback.vibrate();
                                            setState(() {
                                              widget.shuffleMode == 'on'
                                                  ? widget.shuffleMode = 'off'
                                                  : widget.shuffleMode = 'on';
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // * 6th row
                        Expanded(
                          flex: 3,
                          child: Text(''),
                        ),
                      ],
                    ),
                  ),
                  openMenu ? GradientMenu(handleMenu: handleMenu) : Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget songProgress(BuildContext context, double width) {
    var style = TextStyle(color: Colors.deepOrange, fontFamily: 'Gotham');
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                _formatDuration(widget.position),
                style: style,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                _formatDuration(widget.duration),
                style: style,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: RetroSliderTrackShape(
                        sliderPos: widget.slider, width: width),
                    trackHeight: 8,
                    overlayColor: Colors.transparent,
                    activeTrackColor: Color.fromARGB(255, 228, 82, 23),
                    inactiveTrackColor: Color.fromARGB(255, 218, 178, 33),
                    thumbShape: RetroSliderThumbShape(thumbRadius: 8),
                  ),
                  child: Slider(
                    value: widget.slider ?? 0,
                    onChanged: (value) {
                      setState(() {
                        widget.slider = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (widget.duration != null) {
                        Duration msec = Duration(
                            milliseconds:
                                (widget.duration.inMilliseconds * value)
                                    .round());
                        AudioManager.instance.seekTo(msec);
                      }
                    },
                  )),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }
}
