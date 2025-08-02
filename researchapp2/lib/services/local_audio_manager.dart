// Local Audio Manager for Demo App
// Simplified audio file management for pre-generated episode content

import 'package:flutter/foundation.dart';

class LocalAudioManager {
  
  /// Get the local audio path for a specific episode
  static String getEpisodeAudioPath(String journey, int episode) {
    // Map journey IDs to actual folder names
    final String folderName;
    switch (journey) {
      case 'dsa':
        folderName = 'dsa';
        break;
      case 'science_mysteries':
        folderName = 'science_mysteries';
        break;
      case 'psychology':
        folderName = 'psychology';
        break;
      case 'finance':
      case 'personal_finance':
        folderName = 'finance';
        break;
      default:
        folderName = journey;
    }
    return 'assets/audio/learning_journeys/$folderName/episode_$episode/audio.mp3';
  }

  /// Check if audio file exists locally
  static Future<bool> audioExists(String path) async {
    try {
      if (kIsWeb) {
        // For web, assume assets exist (they're bundled)
        return true;
      }
      
      // For mobile, check if asset exists
      // Note: Asset files are bundled, so they should always exist if properly included
      return true; // Assets are checked at build time
    } catch (e) {
      debugPrint('Error checking audio file: $e');
      return false;
    }
  }

  /// Get all available episodes for a journey
  static Future<List<int>> getAvailableEpisodes(String journey) async {
    try {
      // For demo app, return predefined episode numbers based on journey
      switch (journey) {
        case 'data_structures_algorithms':
        case 'dsa':
          return [1, 2, 3, 4, 5, 6]; // Episodes 1-6 available
        case 'science_mysteries':
          return [1, 2, 3, 4, 5]; // Episodes 1-5 available
        case 'psychology':
          return [1, 2, 3, 4, 5]; // Episodes 1-5 available
        case 'personal_finance':
        case 'finance':
          return [1, 2, 3, 4, 5]; // Episodes 1-5 available
        default:
          return [];
      }
    } catch (e) {
      debugPrint('Error getting available episodes: $e');
      return [];
    }
  }

  /// Get journey metadata
  static Map<String, dynamic> getJourneyMetadata(String journey) {
    final journeyData = {
      'dsa': {
        'title': 'Data Structures & Algorithms',
        'description': 'Master the fundamentals of computer science through engaging conversations',
        'totalEpisodes': 6,
        'estimatedDuration': '42 minutes',
        'difficulty': 'Beginner',
        'category': 'Computer Science',
      },
      'data_structures_algorithms': {
        'title': 'Data Structures & Algorithms',
        'description': 'Master the fundamentals of computer science through engaging conversations',
        'totalEpisodes': 6,
        'estimatedDuration': '42 minutes',
        'difficulty': 'Beginner',
        'category': 'Computer Science',
      },
      'science_mysteries': {
        'title': 'Science Mysteries & Discoveries',
        'description': 'Explore the fascinating mysteries of our universe and groundbreaking discoveries',
        'totalEpisodes': 5,
        'estimatedDuration': '40 minutes',
        'difficulty': 'Beginner',
        'category': 'Science',
      },
      'psychology': {
        'title': 'Psychology & Human Behavior',
        'description': 'Discover the fascinating world of human psychology and behavior',
        'totalEpisodes': 5,
        'estimatedDuration': '40 minutes',
        'difficulty': 'Beginner',
        'category': 'Psychology',
      },
      'finance': {
        'title': 'Personal Finance Mastery',
        'description': 'Build wealth and financial security through smart money management',
        'totalEpisodes': 5,
        'estimatedDuration': '35 minutes',
        'difficulty': 'Beginner',
        'category': 'Finance',
      },
      'personal_finance': {
        'title': 'Personal Finance Mastery',
        'description': 'Build wealth and financial security through smart money management',
        'totalEpisodes': 5,
        'estimatedDuration': '35 minutes',
        'difficulty': 'Beginner',
        'category': 'Finance',
      },
    };

    return journeyData[journey] ?? {
      'title': 'Unknown Journey',
      'description': 'No description available',
      'totalEpisodes': 0,
      'estimatedDuration': '0 minutes',
      'difficulty': 'Unknown',
      'category': 'General',
    };
  }

  /// Get episode metadata
  static Map<String, dynamic> getEpisodeMetadata(String journey, int episode) {
    // Episode data matching our ElevenLabs Studio scripts
    final episodeData = {
      'data_structures_algorithms': {
        1: {
          'title': 'Big O Notation & Complexity Analysis',
          'description': 'Understanding time and space complexity with Big O notation',
          'duration': '8:30',
          'topics': ['Big O', 'Time Complexity', 'Space Complexity', 'Algorithm Analysis'],
        },
        2: {
          'title': 'Arrays & Array Operations',
          'description': 'Deep dive into array operations and memory management',
          'duration': '7:45',
          'topics': ['Arrays', 'Memory Management', 'Array Operations', 'Dynamic Arrays'],
        },
        3: {
          'title': 'Linked Lists Deep Dive',
          'description': 'Understanding linked list structures and pointer manipulation',
          'duration': '8:15',
          'topics': ['Linked Lists', 'Pointers', 'Node Structures', 'List Operations'],
        },
        4: {
          'title': 'Stacks & Queues - LIFO vs FIFO',
          'description': 'Building efficient stacks and queues with real-world applications',
          'duration': '9:00',
          'topics': ['Stacks', 'Queues', 'LIFO', 'FIFO', 'Implementation Patterns'],
        },
        5: {
          'title': 'Recursion & Base Cases',
          'description': 'Mastering recursive thinking and base case identification',
          'duration': '8:45',
          'topics': ['Recursion', 'Base Cases', 'Recursive Algorithms', 'Problem Solving'],
        },
        6: {
          'title': 'Sorting Algorithms: Bringing Order to Chaos',
          'description': 'Learn how different sorting algorithms organize data efficiently',
          'duration': '7:00',
          'topics': ['Bubble Sort', 'Quick Sort', 'Merge Sort', 'Time Complexity'],
        },
      },
      'science_mysteries': {
        1: {
          'title': 'Quantum Physics: The Strange World of the Very Small',
          'description': 'Explore the mind-bending world of quantum mechanics and particle behavior',
          'duration': '8:00',
          'topics': ['Wave-particle duality', 'Quantum entanglement', 'Uncertainty principle', 'Quantum mechanics'],
        },
        2: {
          'title': 'Black Holes: The Universe\'s Ultimate Mystery',
          'description': 'Journey into the cosmic phenomena that bend space and time',
          'duration': '8:00',
          'topics': ['Event horizon', 'Hawking radiation', 'Spacetime curvature', 'General relativity'],
        },
        3: {
          'title': 'Ocean Mysteries: Secrets of the Deep',
          'description': 'Dive into the unexplored depths of our planet\'s oceans',
          'duration': '8:00',
          'topics': ['Deep sea creatures', 'Ocean currents', 'Underwater ecosystems', 'Marine biology'],
        },
        4: {
          'title': 'The Human Brain: Consciousness and Memory',
          'description': 'Unravel the mysteries of consciousness and how memories form',
          'duration': '8:00',
          'topics': ['Neural networks', 'Memory formation', 'Consciousness theories', 'Neuroscience'],
        },
        5: {
          'title': 'Evolution in Action: Life\'s Greatest Experiment',
          'description': 'Witness evolution\'s ongoing experiments in adaptation and survival',
          'duration': '8:00',
          'topics': ['Natural selection', 'Genetic variation', 'Adaptation mechanisms', 'Evolutionary biology'],
        },
      },
      'psychology': {
        1: {
          'title': 'Why We Make Bad Decisions',
          'description': 'Explore the cognitive biases and mental shortcuts that lead us astray',
          'duration': '8:00',
          'topics': ['Cognitive biases', 'Heuristics', 'Decision-making errors', 'Behavioral psychology'],
        },
        2: {
          'title': 'The Psychology of Procrastination',
          'description': 'Understand why we delay and how to overcome the procrastination trap',
          'duration': '8:00',
          'topics': ['Temporal discounting', 'Task aversion', 'Overcoming strategies', 'Motivation psychology'],
        },
        3: {
          'title': 'How Beliefs Shape Reality',
          'description': 'Discover how our beliefs influence perception and behavior',
          'duration': '8:00',
          'topics': ['Confirmation bias', 'Belief formation', 'Reality perception', 'Cognitive psychology'],
        },
        4: {
          'title': 'The Science of Relationships',
          'description': 'Explore what psychology reveals about human connections and love',
          'duration': '8:00',
          'topics': ['Attachment styles', 'Love psychology', 'Social bonding', 'Relationship psychology'],
        },
        5: {
          'title': 'Building Better Habits',
          'description': 'Learn the psychology behind habit formation and behavior change',
          'duration': '8:00',
          'topics': ['Habit loop', 'Behavioral change', 'Neural pathways', 'Habit psychology'],
        },
      },
      'personal_finance': {
        1: {
          'title': 'Money Mindset: Your Relationship with Money',
          'description': 'Discover how your beliefs about money impact your financial decisions',
          'duration': '7:00',
          'topics': ['Money psychology', 'Financial beliefs', 'Mindset shifts', 'Financial behavior'],
        },
        2: {
          'title': 'Budgeting Made Simple',
          'description': 'Learn practical budgeting strategies that actually work',
          'duration': '7:00',
          'topics': ['Budget categories', 'Tracking expenses', 'Financial planning', 'Money management'],
        },
        3: {
          'title': 'Emergency Funds: Your Financial Safety Net',
          'description': 'Build a solid emergency fund to protect your financial future',
          'duration': '7:00',
          'topics': ['Emergency planning', 'Savings strategies', 'Risk management', 'Financial security'],
        },
        4: {
          'title': 'Investing Basics: Growing Your Money',
          'description': 'Start your investment journey with confidence and knowledge',
          'duration': '7:00',
          'topics': ['Investment types', 'Risk vs return', 'Portfolio basics', 'Wealth building'],
        },
        5: {
          'title': 'Debt Management Strategies',
          'description': 'Master effective strategies to eliminate debt and stay debt-free',
          'duration': '7:00',
          'topics': ['Debt types', 'Payoff strategies', 'Financial freedom', 'Debt elimination'],
        },
        6: {
          'title': 'Credit Management & Debt Strategy',
          'description': 'Managing credit effectively and debt elimination strategies',
          'duration': '8:10',
          'topics': ['Credit Management', 'Debt Strategy', 'Credit Score', 'Debt Payoff'],
        },
      },
    };

    return episodeData[journey]?[episode] ?? {
      'title': 'Episode $episode',
      'description': 'Episode description not available',
      'duration': '8:00',
      'topics': [],
    };
  }

  /// Validate audio asset path format
  static bool isValidAudioPath(String path) {
    final validPattern = RegExp(r'^assets/audio/learning_journeys/[a-z_]+/episode_\d+/audio\.mp3$');
    return validPattern.hasMatch(path);
  }

  /// Get demo audio URL (placeholder for development)
  static String? getDemoAudioUrl(String journey, int episode) {
    // For demo purposes, return null to indicate no remote audio
    // In production, this could return URLs to sample audio files
    return null;
  }
}
