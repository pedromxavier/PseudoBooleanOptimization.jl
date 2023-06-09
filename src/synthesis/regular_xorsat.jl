@doc raw"""

Generates a ``k``-regurlar ``k``-XORSAT instance with ``n`` boolean variables.
"""
function k_regular_k_xorsat(
    rng,
    ::Type{F},
    n::Integer,
    k::Integer;
    quad::Union{Quadratization,Nothing} = nothing,
) where {V,T,F<:AbstractFunction{V,T}}
    idx = zeros(Int, n, k)

    for j = 1:k, i = 1:n
        idx[i,j] = i
    end

    A = Matrix{Int}(undef, n, n)
    b = Vector{Int}(undef, n)
    c = Vector{Int}(undef, n)

    u = Vector{Int}(undef, n)

    while true
        while true
            _colwise_shuffle!(rng, idx)

            if _rowwise_allunique(idx, u)
                break
            end
        end

        A .= 0

        for i = 1:n, j = 1:k, l = 1:n
            A[i, idx[l, j]] = 1
        end

        rand!(rng, b, (0, 1))

        c .= b # copy values before elimination

        num_solutions = _mod2_numsolutions!(A, b)

        if num_solutions > 0
            # Convert to boolean
            # s = 2x - 1
            f = sum((-1.0)^c[i] * prod([F(idx[i,j] => 2.0, -1.0) for j = 1:k]) for i = 1:n)

            return quadratize!(f, quad)
        end
    end

    return nothing
end

"""
    r_regular_k_xorsat(rng, r::Integer, k::Integer; quad::QuadratizationMethod)

Generates a ``r``-regurlar ``k``-XORSAT instance with ``n`` boolean variables.

If ``r = k``, then falls back to [`k_regular_k_xorsat`](@ref).
"""
function r_regular_k_xorsat(
    rng,
    ::Type{F},
    n::Integer,
    r::Integer,
    k::Integer;
    quad::Union{Quadratization,Nothing} = nothing,
) where {V,T,F<:AbstractFunction{V,T}}
    if r == k
        return k_regular_k_xorsat(rng, F, n, k; quad)
    else
        # NOTE: This might involve Sudoku solving!
        error("A method for generating r-regular k-XORSAT where r ≂̸ k is not implemented")
    end
end
