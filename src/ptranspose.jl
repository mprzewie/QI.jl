"""
$(SIGNATURES)
- `ρ`: quantum state.
- `idims`: dimensins of subsystems.
- `isystems`: transposed subsystems.

Return [partial transposition](http://en.wikipedia.org/wiki/Peres-Horodecki_criterion) of matrix `ρ` over the subsystems determined by `isystems`.
"""
function ptranspose(ρ::AbstractMatrix{<:Number}, idims::Vector{Int}, isystems::Vector{Int})
    dims=reverse(idims)
    systems=length(idims)-isystems+1

    if size(ρ,1)!=size(ρ,2)
        throw(ArgumentError("Non square matrix passed to ptrace"))
    end
    if prod(dims)!=size(ρ,1)
        throw(ArgumentError("Product of dimensions do not match shape of matrix."))
    end
    if maximum(systems) > length(dims) ||  minimum(systems) < 1
        throw(ArgumentError("System index out of range"))
    end

    offset = length(dims)
    tensor = reshape(ρ, [dims; dims]...)
    perm = collect(1:(2offset))
    for s in systems
        idx1 = find(x->x==s, perm)[1]
        idx2 = find(x->x==(s + offset), perm)[1]
        perm[idx1], perm[idx2] = perm[idx2], perm[idx1]
    end
    tensor = permutedims(tensor, invperm(perm))
    reshape(tensor, size(ρ))
end

ptranspose(ρ::AbstractMatrix{<:Number}, idims::Vector{Int}, sys::Int) = ptranspose(ρ, idims, [sys])

function ptranspose(ρ::AbstractSparseMatrix{<:Number}, dims::Vector{Int}, sys::Int)

    if size(ρ,1)!=size(ρ,2)
        throw(ArgumentError("Non square matrix passed to ptrace"))
    end
    if prod(dims)!=size(ρ,1)
        throw(ArgumentError("Product of dimensions do not match shape of matrix."))
    end

    if sys != 1 && sys != 2
        throw(ArgumentError("sys must be 1 or 2, not $sys"))
    end

    I, J, V = findnz(ρ)
    newI = zeros(I)
    newJ = zeros(J)
    for k=1:length(I)
        i, j = number2mixedradix(I[k]-1, dims), number2mixedradix(J[k]-1, dims)
        i[sys], j[sys] = j[sys], i[sys]
        newI[k], newJ[k] = mixedradix2number(i, dims), mixedradix2number(j, dims)
    end
    sparse(newI+1, newJ+1, V, size(ρ)...)
end
