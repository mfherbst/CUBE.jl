```@meta
CurrentModule = CUBE
```

# CUBE

Documentation for [CUBE](https://github.com/mfherbst/CUBE.jl).

Read and write [Gaussian cube files](http://paulbourke.net/dataformats/cube/) from Julia.
For now just a rudimentary proof of principle implementation.

## Examples
**Reading** data works like this:
```julia
using CUBE

cube = CUBE.read("water.cube")
```
The resulting `CubeFile` struct holds the information about the molecular
structure (`cube.system`) or the data stored in the cube file (`cube.data`).

**Saving** is just the reverse process, i.e. storing such a struct to disk:
```julia
using CUBE
CUBE.save("water.cube", cube)
```

## References
- http://paulbourke.net/dataformats/cube/
- https://h5cube-spec.readthedocs.io/en/latest/cubeformat.html
- http://gaussian.com/cubegen/


```@index
```

```@autodocs
Modules = [CUBE]
```
