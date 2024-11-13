import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:photo_view/photo_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureCharacters; // define future 


   // function for fetching data from API
   Future<List<dynamic>> fetchDisneyCharacters() async {
    final url = Uri.parse("https://api.disneyapi.dev/character");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];  
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    futureCharacters = fetchDisneyCharacters();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 26, 26),
        title: const Text(
          "Unit 7 Assignment",
          style: TextStyle(
            color: Colors.white,
          ),
          ),
          centerTitle: true,
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(22.0),
            child: Text(
              "Disney Characters",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

           
          Expanded(
            child: FutureBuilder(
              // Setup the URL for your API here
              future: futureCharacters,
              builder: (context, snapshot) {
                // Consider 3 cases here
                // When the process is ongoing
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } 

                // When the process is completed
                else if (snapshot.hasData) {
                  final characters = snapshot.data as List;

                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: ListView.builder(
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        final controller = ExpandedTileController();

                        final String fallbackDescription = (character['films'] != null && character['films'].isNotEmpty)
                            ? 'Films: ${character['films'].join(", ")}'
                            : (character['tvShows'] != null && character['tvShows'].isNotEmpty)
                                ? 'TV Shows: ${character['tvShows'].join(", ")}'
                                : 'No description available.';

                        final String fallbackAdditionalDetails = (character['videoGames'] != null && character['videoGames'].isNotEmpty)
                            ? 'Video Games: ${character['videoGames'].join(", ")}'
                            : (character['parkAttractions'] != null && character['parkAttractions'].isNotEmpty)
                                ? 'Park Attractions: ${character['parkAttractions'].join(", ")}'
                                : 'No additional details available.';

                        return ExpandedTile(
                          controller: controller,
                          title: Text(character['name'] ?? 'Unknown'),
                          leading: character['imageUrl'] != null && character['imageUrl'].isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true, 
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent, 
                                          child: Stack(
                                            children: [
                                              Container(
                                                color: Colors.black.withOpacity(0.7),  
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),

                                              Center(
                                                child: PhotoView(
                                                  imageProvider: NetworkImage(character['imageUrl']),
                                                  minScale: PhotoViewComputedScale.contained,
                                                  maxScale: PhotoViewComputedScale.covered,
                                                ),
                                              ),
                                          
                                              Positioned(
                                                top: 30,  
                                                left: 10,  
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.arrow_back,
                                                    color: Colors.white,  
                                                    size: 25,  
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); 
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Image.network(
                                    character['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) {
                                        return child; 
                                      } else {
                                        return const Center(child: CircularProgressIndicator());  
                                      }
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                          
                                      return Container(
                                        color: Colors.grey[300],
                                        width: 50,
                                        height: 50,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const Icon(Icons.image_not_supported),

                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(fallbackDescription),
                              const SizedBox(height: 5),
                              Text(fallbackAdditionalDetails),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }

                // error
                else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return const Center(child: Text('No data available.'));
              },
            ),
          ),
        ],
      ),

    );
  }
}
