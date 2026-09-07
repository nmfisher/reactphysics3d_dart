import 'dart:typed_data';
import 'package:reactphysics3d_dart/reactphysics3d_dart.dart';

/// Example demonstrating heightfield terrain creation and usage
void main() {
  // Initialize ReactPhysics3D
  final physics3d = createReactPhysics3D();

  try {
    // Create heightfield terrain data
    print('Creating heightfield terrain...');

    const int rows = 5;
    const int columns = 5;

    // Generate a simple height map (can be replaced with actual terrain data)
    final heights = List<double>.generate(rows * columns, (index) {
      final int row = index ~/ columns;
      final int col = index % columns;
      // Create a simple hill shape
      final double centerX = columns / 2.0;
      final double centerY = rows / 2.0;
      final double distance =
          ((col - centerX) * (col - centerX) +
          (row - centerY) * (row - centerY));
      return 2.0 * (1.0 - distance / 8.0); // Max height 2.0
    });

    // Find min and max heights for optimization
    final double minHeight = heights.reduce((a, b) => a < b ? a : b);
    final double maxHeight = heights.reduce((a, b) => a > b ? a : b);

    print('Height range: $minHeight to $maxHeight');
    print('Heights: $heights');

    // Create height field
    final heightField = physics3d.createHeightFieldFloat(
      rows: rows,
      columns: columns,
      heights: Float32List.fromList(heights),
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    // Create height field shape
    final heightFieldShape = physics3d.createHeightFieldShape(heightField);

    print('Heightfield created successfully!');

    // Demonstrate integer height field creation
    print('\nCreating integer heightfield...');

    // Generate integer height data (common in terrain heightmaps)
    final intHeights = List<int>.generate(rows * columns, (index) {
      final int row = index ~/ columns;
      final int col = index % columns;
      // Create integer heights (e.g., from heightmap data)
      final double centerX = columns / 2.0;
      final double centerY = rows / 2.0;
      final double distance =
          ((col - centerX) * (col - centerX) +
          (row - centerY) * (row - centerY));
      return (100 * (1.0 - distance / 8.0)).round(); // Integer heights 0-100
    });

    print('Integer heights: $intHeights');

    // Create integer height field with scaling factor
    final double integerHeightScale =
        0.1; // Convert integer units to world units
    final intHeightField = physics3d.createHeightFieldInt(
      rows: rows,
      columns: columns,
      heights: Int32List.fromList(intHeights),
      minHeight: 0.0,
      maxHeight: 10.0,
      integerHeightScale: integerHeightScale,
    );

    // Create height field shape from integer data
    final intHeightFieldShape = physics3d.createHeightFieldShape(
      intHeightField,
    );

    print('Integer heightfield created successfully!');

    // Test getting vertices from the heightfield
    print('\nTesting heightfield vertex access:');
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final vertex = heightFieldShape.getVertexAt(row, col);
        print(
          'Vertex at ($row, $col): (${vertex.x.toStringAsFixed(2)}, ${vertex.y.toStringAsFixed(2)}, ${vertex.z.toStringAsFixed(2)})',
        );
      }
    }

    print('\nHeightfield implementation test completed successfully!');

    // Cleanup
    print('Cleaning up...');
    heightFieldShape.dispose();
    heightField.dispose();
    intHeightFieldShape.dispose();
    intHeightField.dispose();
  } catch (e) {
    print('Error: $e');
    print('Stack trace: ${StackTrace.current}');
  } finally {
    physics3d.dispose();
  }
}
