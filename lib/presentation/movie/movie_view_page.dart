import 'package:flutter/material.dart';
import 'package:flutter_app_demo/application/movie/movie_bloc.dart';
import 'package:flutter_app_demo/application/core/network/network_bloc.dart';
import 'package:flutter_app_demo/presentation/components/blank_page_with_message.dart';
import 'package:flutter_app_demo/presentation/movie/movie_detail_page.dart';
import 'package:flutter_app_demo/presentation/presentation_const.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'movie_display_widget.dart';

class MoviePage extends StatefulWidget{
  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> with SingleTickerProviderStateMixin{
  AnimationController _movieAnimationController;

  @override
  void initState() {
    super.initState();
    _movieAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _movieAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkBloc, NetworkState>(
      listenWhen: (previous, current) => previous != current,
      listener: (BuildContext context, state) {
        var messenger = ScaffoldMessenger.of(context);
        if (state is NetworkLostConnectionState) {
          // Notify user that connection is lost
          messenger.showSnackBar(kLostConnectionSnackBar);
        } else if (state is NetworkConnectedState) {
          // Notify user that connection is regained
          messenger.showSnackBar(kRegainedConnectionSnackBar);
        }
      },
      child: BlocBuilder<MovieBloc, MovieState>(
        builder: (BuildContext context, state) {
          if (state is MovieLoadedSuccessfulState) {
            if (!_movieAnimationController.isAnimating) {
              _movieAnimationController.forward(from: 0);
            }
            return Container(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                  childAspectRatio: 0.618,
                ),
                itemCount: state.movies.length,
                itemBuilder: (context, index) {
                  return MovieDisplayWidget(
                    movie: state.movies[index],
                    animationController: _movieAnimationController,
                    offsetMultiplier: index ~/ 2,
                  );
                }
              ),
            );
          } else if (state is MovieShowDetailState) {
            return MovieDetailPage(movie: state.movie);
          } else if (state is MovieLoadingState) {
            return BlankPageMessageWidget(message: 'Connected to internet, loading...',);
          } else if (state is MovieErrorState) {
            return BlankPageMessageWidget(message: 'Error. Could not retrieve data from Internet',);
          } else {
            return BlankPageMessageWidget(message: 'Loading...',);
          }
        },
      )
    );
  }
}

