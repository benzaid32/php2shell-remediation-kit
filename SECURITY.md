# Security policy

## Scope

This repository contains defensive documentation and local, read-only audit scripts. It does not contain exploit code and does not scan third-party systems.

## Reporting a problem with this kit

If you find a bug in the scripts or a factual error in the documentation:

- open a GitHub issue with the affected file and a minimal reproduction;
- do **not** include credentials, customer data, or third-party host details;
- for security-sensitive issues in the scripts themselves, use GitHub's private vulnerability reporting feature if it is enabled for this repository.

## Reporting the PHP vulnerabilities

This project is not the vendor. Report issues in PHP to the PHP project or your distribution:

- https://www.php.net/security
- https://github.com/php/php-src/security

## Out of scope

The maintainers cannot help with:

- testing or exploiting systems without authorization;
- target lists or internet-wide scanning;
- incident response for a compromised host (engage a qualified provider);
- warranty or liability for production changes.

## Safe use

Run the scripts only on hosts you own or are explicitly authorized to administer. The audit scripts are read-only, but you are responsible for reviewing the commands and output before making production changes.
