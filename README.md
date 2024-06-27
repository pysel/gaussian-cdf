# Paradigm Fellowship Application

## Name: Ruslan Akhtariev

## Email: <rakhtariev@icloud.com>

## Question

Implement a maximally optimized gaussian CDF on the EVM for arbitrary 18 decimal fixed point parameters x, μ, σ. Assume -1e20 ≤ μ ≤ 1e20 and 0 < σ ≤ 1e19. Should have an error less than 1e-8 vs errcw/gaussian for all x on the interval [-1e23, 1e23].

## Testing

To test the implementation, run the following command:

```bash
make test-paradigm
```

It runs default tests for the gaussian CDF implementation.

Note: all outputted values are scaled by 1e18.

## Custom Tests

To run custom tests, you may modify the skeleton code in `test/gcdf.t.sol` and run the following command:

```bash
make test-paradigm
```

Your test will be included to the output.

Note: all outputted values are scaled by 1e18.
