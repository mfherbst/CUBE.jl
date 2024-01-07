using AtomsBase
using CUBE
using Test
using Unitful
using UnitfulAtomic

@testset "CUBE.jl" begin
    mktempdir() do path
        x = CUBE.read(joinpath(@__DIR__, "h2o.cube"))
        out = joinpath(path, "copy.cube")
        CUBE.save(out, x)
        y = CUBE.read(out)

        @test x.comment == y.comment
        @test maximum(abs.(x.data - y.data)) < 1e-5
        @test maximum(abs.(x.origin     - y.origin))     < 1e-5u"bohr"
        @test maximum(maximum(abs, diff)
                      for diff in x.unit_voxel - y.unit_voxel) < 1e-5u"bohr"
        @test maximum(maximum(abs, diff)
                      for diff in position(x.system) - position(y.system)) < 1e-5u"bohr"
        @test atomic_number(x.system) == atomic_number(y.system)
    end
end
