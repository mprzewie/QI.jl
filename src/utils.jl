function number2mixedradix(n::Int, bases::Vector{Int})
    if n >= prod(bases)
        error("number to big to transform")
    end

    digits = Array{Int64}(length(bases))
    for (i, base) in enumerate(reverse(bases))
        n, digits[i] = divrem(n, base)
    end
    digits
end
# FIX THESE
function mixedradix2number(digits::Vector{Int}, bases::Vector{Int})
    if length(digits)>length(bases)
        error("more digits than radices")
    end

    res = 0
    digitsreversed = reverse(digits)
    for i=1:length(digits)
        res = res * bases[i] + digitsreversed[i]
    end
    res
end

function renormalize!(ϕ::AbstractVector{T}) where T<:Union{Real, Complex}
    n = norm(ϕ)
    for i=1:length(ϕ)
        ϕ[i] = ϕ[i]/n
    end
end

function renormalize!(ρ::AbstractMatrix{T}) where T<:Union{Real, Complex}
    t = trace(ρ)
    for i=1:length(ρ)
        ρ[i] = ρ[i]/t
    end
end

function funcmh!(f::Function, H::Hermitian{T}, R::Matrix{T})  where T<:Union{Real, Complex}
    F = eigfact!(H)
    for i=1:length(F.values)
        F.values[i] = f(F.values[i])
    end
    times_diag = zero(F.vectors)
    for i=1:size(F.vectors, 2)
        times_diag[:, i] = F.vectors[:, i] * F.values[i]
    end
    R[:] = times_diag * F.vectors' # A_mul_Bc!(R, times_diag, F.vectors) deprecated
end

function funcmh!(f::Function, H::Hermitian{T}) where T<:Union{Real, Complex}
    R = zeros(T, size(H))
    funcmh!(f, H, R)
    R
end

function funcmh(f::Function, H::Hermitian{T}) where T<:Union{Real, Complex}
    R = zeros(T, size(H))
    funcmh!(f, copy(H), R)
    R
end

function funcmh!(f::Function, H::Matrix{T}, R::Matrix{T}) where T<:Union{Real, Complex}
    ishermitian(H) ? funcmh!(f, Hermitian(H), R) : error("Non-hermitian matrix passed to funcmh")
end

function funcmh!(f::Function, H::Matrix{T}) where T<:Union{Real, Complex}
    ishermitian(H) ? funcmh!(f, Hermitian(H)) : error("Non-hermitian matrix passed to funcmh")
end

function funcmh(f::Function, H::Matrix{T}) where T<:Union{Real, Complex}
    ishermitian(H) ? funcmh(f, Hermitian(H)) : error("Non-hermitian matrix passed to funcmh")
end

random_ball(dim::Int) = rand()^(1/dim) * random_ket(Float64, dim)

#function random_vector_fixed_l1_l2(l1::Real, l2::Real, d::Int)
#  #from here http://stats.stackexchange.com/questions/61692/generating-vectors-under-constraints-on-1-and-2-norm
#  u, _ = qr(ones(d, d))
#  u = -u
#  z = random_sphere(d - 1)
#  z = [0; z]
#  r = sqrt(l2 - l1^2 / d)
#  v = u * z * r
#  return v + l1 / d * ones(d)
#end
