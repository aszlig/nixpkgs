addAclocals () {
    addToSearchPathWithCustomDelimiter : ACLOCAL_PATH $1/share/aclocal
}

addEnvHooks addAclocals
