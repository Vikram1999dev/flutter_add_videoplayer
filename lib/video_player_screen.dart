// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  //this will show button when the videoplayer
  //shows on rendering and also when video ends
  bool _showButton = true;
  //pointing to one of the string
  int? _oneOfTheVideo = 0;
  //to toggle left and right video
  bool _showLeftButton = false;
  bool _showRightButton = true;
  List<String> videos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'
  ];
  //for checking if the video is complete or not
  bool _isVideoComplete = false;
  double _volume = 1.0;

  @override
  void initState() {
    //will have the controller of the video player
    _controller = VideoPlayerController.network(
      videos[_oneOfTheVideo!],
    );
    //will help us initialize
    //it can take time that's why it is associated with
    //future of FutureBuilder
    _initializeVideoPlayerFuture = _controller!.initialize();
    //to avoid looping of the video
    _controller!.setLooping(false);
    // Add listener to check for end of video
    _controller!.addListener(() {
      if (_controller!.value.position == _controller!.value.duration) {
        setState(() {
          _isVideoComplete = true;
          _showButton = true;
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  //this function will initialize the videoplayer
  //every single time when we toggle that video
  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.network(
      videos[_oneOfTheVideo!],
    );
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(false);
    _controller!.addListener(() {
      if (_controller!.value.position == _controller!.value.duration) {
        setState(() {
          _isVideoComplete = true;
          _showButton = true;
        });
      }
    });
  }

//this function will be called whenever the chevron icon button is
//clicked so as not to be depenedent upon the init lifecycle method
  void _updateState() {
    _initializeVideoPlayer();
    setState(() {
      if (_oneOfTheVideo == 0) {
        _showLeftButton = _oneOfTheVideo == 1;
        _showRightButton = true;
        //this will make sure that whenever we open
        //new video the middle icon button never displays replay button
        _isVideoComplete = false;
      } else {
        _showRightButton = _oneOfTheVideo == 0;
        _showLeftButton = true;
        _isVideoComplete = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bee Video'),
      ),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(
                  //to detect gesture on videoplayer and not on icon button
                  //to display or not display the next pause/play and previous
                  //icon

                  child: GestureDetector(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                    onTap: () {
                      setState(() {
                        _showButton = !_showButton;
                      });
                    },
                  ),
                ),
                Visibility(
                  //will show button which will be dependent upon
                  //the tap gesture on the videoplayer
                  visible: _showButton,
                  child: Positioned.fill(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            color: Colors.white,
                            onPressed: _showLeftButton
                                ? () {
                                    setState(() {
                                      _oneOfTheVideo = 0;
                                      _updateState();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          IconButton(
                            color: Colors.white,
                            splashColor: Colors.white,
                            icon: _isVideoComplete
                                ? const Icon(Icons.replay)
                                : //whenever the video is still playing
                                //it the middle icon button will
                                //toggle between pause and play
                                Icon(_controller!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow),
                            onPressed: _showButton
                                ? () async {
                                    if (_isVideoComplete) {
                                      await _controller?.seekTo(Duration.zero);
                                      setState(() {
                                        _isVideoComplete = false;
                                      });
                                    }
                                    setState(() {
                                      if (_controller?.value.isPlaying ??
                                          false) {
                                        _controller?.pause();
                                      } else {
                                        _controller?.play();
                                      }
                                    });
                                  }
                                : null,
                          ),
                          IconButton(
                            color: Colors.white,
                            onPressed: _showRightButton
                                ? () {
                                    setState(() {
                                      _oneOfTheVideo = 1;
                                      _updateState();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showButton,
                  child: Positioned.fill(
                    top: 180,
                    // top edge is set to 100% of the height of the parent widget
                    // right: 160,
                    left: 220,
                    child: SizedBox(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_down,
                            color: Colors.white,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: const SliderThemeData(
                                // adjust the height of the slider track
                                trackHeight: 5,
                                thumbShape: RoundSliderThumbShape(
                                  // adjust the size of the slider thumb
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                value: _volume,
                                onChanged: (value) {
                                  setState(() {
                                    _volume = value;
                                  });
                                  _controller!.setVolume(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
