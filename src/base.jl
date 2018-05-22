function ket(::Type{Tv}, val::Int, dim::Int) where Tv<:AbstractVector{T} where T<:Number
    dim > 0 ? () : throw(ArgumentError("Vector dimension has to be nonnegative"))
    val < dim ? () : throw(ArgumentError("Label have to be smaller than vector dimmension"))
    ϕ = zeros(T, dim)
    ϕ[val+1] = one(T)
    ϕ
end

function ket(::Type{Tv}, val::Int, dim::Int) where Tv<:AbstractSparseVector{T} where T<:Number
    dim > 0 ? () : throw(ArgumentError("Vector dimension has to be nonnegative"))
    val < dim ? () : throw(ArgumentError("Label have to be smaller than vector dimmension"))
    ϕ = spzeros(T, dim)
    ϕ[val+1] = one(T)
    ϕ
end

"""
    $(SIGNATURES)

  - `val::Int`: non-zero entry - label.
  - `dim::Int`: length of the vector.
  - `sparse:Bool` : sparse\/dense option. Optional `sparse=false`.

    Return column vector describing quantum state
"""
function ket(val::Int, dim::Int; sparse=false)
    if sparse
        return ket(SparseVector{ComplexF64}, val, dim)
    else
        return ket(Vector{ComplexF64}, val, dim)
    end
end


bra(::Type{Tv}, val::Int, dim::Int) where Tv<:AbstractVector{T} where T<:Number = ket(Tv, val, dim)'

"""
  $(SIGNATURES)

  - `val::Int`: non-zero entry - label.
  - `dim::Int`: length of the vector
  - `sparse:Bool` : sparse\/dense option. Optional `sparse=false`.

  Return Hermitian conjugate of the ket with the same label.
"""
function bra(val::Int, dim::Int; sparse=false)
    if sparse
        return bra(SparseVector{ComplexF64}, val, dim)
    else
        return bra(Vector{ComplexF64}, val, dim)
    end
end

function ketbra(::Type{Tv}, valk::Int, valb::Int, dim::Int) where Tv<:AbstractMatrix{T} where T<:Number
    dim > 0 ? () : throw(ArgumentError("Vector dimension has to be nonnegative"))
    valk < dim && valb < dim ? () : throw(ArgumentError("Ket and bra labels have to be smaller than operator dimmension"))
    ϕψ = zeros(T, dim, dim)
    ϕψ[valk+1,valb+1] = one(T)
    ϕψ
end

function ketbra(::Type{Tv}, valk::Int, valb::Int, dim::Int) where Tv<:AbstractSparseMatrix{T} where T<:Number
    dim > 0 ? () : throw(ArgumentError("Vector dimension has to be nonnegative"))
    valk < dim && valb < dim ? () : throw(ArgumentError("Ket and bra labels have to be smaller than operator dimmension"))
    ϕψ = spzeros(T, dim, dim)
    ϕψ[valk+1,valb+1] = one(T)
    ϕψ
end

function ketbra(valk::Int, valb::Int, dim::Int; sparse=false)
    if sparse
        return ketbra(SparseMatrixCSC{ComplexF64}, valk, valb, dim)
    else
        return ketbra(Matrix{ComplexF64}, valk, valb, dim)
    end
end

proj(ket::AbstractVector{T}) where T<:Number = ket * ket'

# function base_matrices(dim)
#     function _it()
#         for i=0:dim-1, j=0:dim-1
#             produce(ketbra(j, i, dim))
#         end
#     end
#     Task(_it)
# end

base_matrices(dim) = Channel() do c
    dim > 0 ? () : error("Operator dimension has to be nonnegative")
    for i=0:dim-1, j=0:dim-1
        push!(c, ketbra(j, i, dim))
    end
end

res(ρ::AbstractMatrix{T}) where T<:Number = vec(transpose(ρ))

function unres(ϕ::AbstractVector{T}, cols::Int) where T<:Number
    dim = length(ϕ)
    rows = div(dim, cols)
    rows*cols == length(ϕ) ? () : error("Wrong number of columns")
    transpose(reshape(ϕ, cols, rows))
end

function unres(ϕ::AbstractVector{T}) where T<:Number
    dim = size(ϕ, 1)
    s = isqrt(dim)
    unres(ϕ, s)
end

unres(ϕ::AbstractVector{T}, m::Int, n::Int) where T<:Number = transpose(reshape(ϕ, n, m))

<<<<<<< HEAD
=======
"""
Transforms list of Kraus operators into super-operator matrix.
"""
function kraus_to_superoperator(kraus_list::Vector{T}) where {T<:AbstractMatrix{T1}} where {T1<:Number}
    # TODO: chceck if all Kraus operators are the same shape
    sum((k) -> kron(k, k'), kraus_list)
end

function channel_to_superoperator(channel::Function, dim::Int)
    dim > 0 ? () : error("Channel dimension has to be nonnegative")

    M = zeros(ComplexF64, dim*dim, dim*dim)
    for (i, e) in enumerate(base_matrices(dim))
        M[:, i] = res(channel(e))
    end
    M
end

>>>>>>> documentation
# TODO: allow different type of Kraus operators and the quantum state
function apply_kraus(kraus_list::Vector{T}, ρ::T) where {T<:AbstractMatrix{T1}} where {T1<:Number}
    # TODO: chceck if all Kraus operators are the same shape and fit the input state
    sum(k-> k*ρ*k', kraus_list)
end

max_mixed(d::Int; sparse=false) = sparse ? speye(ComplexF64, d, d)/d : eye(ComplexF64, d, d)/d

function max_entangled(d::Int; sparse=false)
    sd = isqrt(d)
    ϕ = sparse ? res(speye(ComplexF64, sd, sd)) : res(eye(ComplexF64, sd, sd))
    renormalize!(ϕ)
    ϕ
end

"""
<<<<<<< HEAD
http://en.wikipedia.org/wiki/Werner_state
"""
function werner_state(d::Int, α::Float64,)
    α > 1 || α < 0 ? throw(ArgumentError("α must be in [0, 1]")) : ()
    α * proj(max_entangled(d)) + (1 - α) * max_mixed(d)
end

#=
TODO: port to julia
def base_hermitian_matrices(dim):
    """
    Generator. Returns elementary hermitian matrices of dimension dim x dim.
    """
    for (a, b) in product(xrange(dim), repeat=2):
        if a > b:
            yield 1 / np.sqrt(2) * np.matrix(1j * ketbra(a, b, dim) - 1j * ketbra(b, a, dim))
        elif a < b:
            yield 1 / np.sqrt(2) * np.matrix(ketbra(a, b, dim) + ketbra(b, a, dim))
        else:
            yield np.matrix(ketbra(a, b, dim))


def permute_systems(rho, dims, systemperm):
    rho = np.asarray(rho)
    dims = list(dims)
    systemperm = list(systemperm)
    if rho.shape[0] != rho.shape[1]:
        raise Exception("Non square matrix passed to ptrace")
    if np.prod(dims) != rho.shape[0]:
        raise Exception("Product of dimensions do not match shape of matrix.")
    if not ((max(systemperm) <= len(dims) or (min(systemperm) > len(dims)))):
        raise Exception("System index out of range")
    offset = len(dims)
    perm1 = systemperm
    perm2 = map(lambda x: x + offset, perm1)
    perm = perm1 + perm2
    tensor = np.array(rho).reshape(2 * dims)
    tensor = tensor.transpose(perm)
    return np.asmatrix(tensor.reshape(rho.shape))
=#
=======
  $(SIGNATURES)

  - `ρ::AbstractMatrix`: reshuffled matrix.

  Performs reshuffling of indices of a matrix.
  Given multiindexed matrix \$M_{(m,μ),(n,ν)}\$ it returns
  matrix \$M_{(m,n),(μ,ν)}\$.
"""
function reshuffle(ρ::AbstractMatrix{T}) where T<:Number
  (r, c) = size(ρ)
  sqrtr = isqrt(r)
  sqrtc = isqrt(c)
  tensor = reshape(ρ, sqrtr, sqrtr, sqrtc, sqrtc)
  perm = [4, 2, 3, 1]
  tensor = permutedims(tensor, perm)
  (r1, r2, c1, c2) = size(tensor)
  return reshape(tensor, r1*r2, c1*c2)
end

"""
  $(SIGNATURES)

  - `ρ::AbstractMatrix`: matrix.
  - `σ::AbstractMatrix`: matrix.
  Original equation:
  \$\\delta(\\rho,\\sigma)=\\frac{1}{2}\\mathrm{tr}(|\\rho-\\sigma|)\$

  Equivalent faster method:
  \$\\delta(A,B)=\\frac{1}{2} \\sum_i \\sigma_i(A-B)\$
  http://www.quantiki.org/wiki/Trace_distance
"""
trace_distance(ρ::AbstractMatrix{T}, σ::AbstractMatrix{T}) where T<:Number = sum(abs.(eigvals(Hermitian(ρ - σ))))

"""
  $(SIGNATURES)

  - `ρ::AbstractMatrix`: matrix.
  - `σ::AbstractMatrix`: matrix.
    Original equation:
    \$\\sqrt{F}(\\rho,\\sigma)=\\textrm{tr}\\sqrt{\\sqrt{\\rho}\\sigma\\sqrt{\\rho}}\$

    http://www.quantiki.org/wiki/Fidelity

    Equivalent faster method:
    \$\\sqrt{F}(\\rho,\\sigma)=\\sum_i \\sqrt{\\lambda_i(AB)}\$

    ``Sub-- and super--fidelity as bounds for quantum fidelity''
    Quantum Information & Computation, Vol.9 No.1&2 (2009)
"""
function fidelity_sqrt(ρ::AbstractMatrix{T}, σ::AbstractMatrix{T}) where T<:Number
  if size(ρ, 1) != size(ρ, 2) || size(σ, 1) != size(σ, 2)
    error("Non square matrix")
  end
  λ = real(eigvals(ρ * σ))
  r = sum(sqrt.(λ[λ.>0]))
end

"""
  $(SIGNATURES)

  - `ρ::AbstractMatrix`: matrix.
  - `σ::AbstractMatrix`: matrix.
  \$F(\\rho,\\sigma)=\\left(\\textrm{tr}\\sqrt{\\sqrt{\\rho}\\sigma\\sqrt{\\rho}}\\right)^2\$

  http://www.quantiki.org/wiki/Fidelity
"""
function fidelity(ρ::AbstractMatrix{T}, σ::AbstractMatrix{T}) where T<:Number
  if size(ρ, 1) != size(ρ, 2) || size(σ, 1) != size(σ, 2)
    error("Non square matrix")
  end
  return fidelity_sqrt(ρ, σ)^2
end

fidelity(ϕ::AbstractVector{T}, ψ::AbstractVector{T}) where T<:Number = abs2(dot(ϕ, ψ))
fidelity(ϕ::AbstractVector{T}, ρ::AbstractMatrix{T}) where T<:Number = ϕ' * ρ * ϕ
fidelity(ρ::AbstractMatrix{T}, ϕ::AbstractVector{T}) where T<:Number = fidelity(ϕ, ρ)

shannon_entropy(p::AbstractVector{T}) where T<:Real = -sum(p .* log.(p))

shannon_entropy(x::T) where T<:Real = x > 0 ? -x * log(x) - (1 - x) * log(1 - x) : error("Negative number passed to shannon_entropy")

"""
  $(SIGNATURES)

    - `ρ::AbstractMatrix`: matrix.
    Calculates the von Neuman entropy of positive matrix \$\\rho\$

    \$S(\\rho)=-tr(\\rho\\log(\\rho))\$

    Equivalent faster form:
    \$S(\\rho)=-\\sum_i \\lambda_i(\\rho)*\\log(\\lambda_i(\\rho))\$
    http://www.quantiki.org/wiki/Von_Neumann_entropy
    """
function entropy(ρ::Hermitian{T}) where T<:Number
    λ = eigvals(ρ)
    λ = λ[λ .> 0]
    -sum(λ .* log(λ))
end

entropy(H::AbstractMatrix{T}) where T<:Number = ishermitian(H) ? entropy(Hermitian(H)) : error("Non-hermitian matrix passed to entropy")
entropy(ϕ::AbstractVector{T}) where T<:Number = zero(T)
>>>>>>> documentation
