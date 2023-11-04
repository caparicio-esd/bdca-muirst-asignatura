// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

/*
 *
 * @title Contract AsignaturaFull - BDCA - MUIRST 2324
 *
 * Authors:
 * - Carlos Aparicio
 * - Enzo Banchon
 * - Paulina Bravo
 *
 */
contract AsignaturaFull {
    // Enums and Structs
    enum TipoNota {
        Empty,
        NP,
        Normal
    }
    struct DatosAlumno {
        string nombre;
        string email;
        string dni;
    }
    struct Evaluacion {
        string nombre;
        uint fecha;
        uint porcentaje;
        uint nota_minima;
    }
    struct Nota {
        TipoNota tipo;
        uint calificacion;
    }

    // simple attrs
    string public version = "2023 Full";
    string public nombre;
    string public curso;
    bool public cerrada;

    // addresses
    address public immutable owner;
    address public profesor;
    address public coordinador;

    // arrays
    address[] public profesores;
    address[] public matriculas;
    Evaluacion[] public evaluaciones;

    // mappings
    mapping(address => DatosAlumno) public datosAlumno;
    mapping(address => string) public datosProfesor;
    mapping(address => mapping(uint => Nota)) public calificaciones;

    /**
     *
     * constructor
     * @dev Deploy contract
     * @param _nombre   {string memory} Asignatura name
     * @param _curso    {string memory} Curso académico
     *
     */
    constructor(string memory _nombre, string memory _curso) {
        require(
            bytes(_nombre).length != 0,
            "El nombre de la asignatura no puede ser vacio"
        );
        require(
            bytes(_curso).length != 0,
            "El curso academico de la asignatura no puede ser vacio"
        );

        profesor = msg.sender;
        nombre = _nombre;
        curso = _curso;
        owner = msg.sender;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // GENERIC METHODS
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * compareStrings
     * @dev pure function to compare string memory vars equality
     * @param _a {string memory}
     * @param _b {string memory}
     *
     */
    function compareStrings(
        string memory _a,
        string memory _b
    ) private pure returns (bool) {
        return (keccak256(abi.encodePacked(_a)) ==
            keccak256(abi.encodePacked(_b)));
    }

    /**
     *
     * doesAlumnoDNIExists
     * @dev view function to handle whether a alumno's dni is already saved
     * @param _dni {string memory} Coordinador address
     *
     */
    function doesAlumnoDNIExists(
        string memory _dni
    ) private view returns (bool boolOut) {
        boolOut = false;
        for (uint i = 0; i < matriculas.length; i++) {
            if (compareStrings(datosAlumno[matriculas[i]].dni, _dni)) {
                boolOut = true;
                break;
            }
        }
    }

    /**
     *
     * estaMatriculado
     * @dev checks whether a alumno, identified by address, is matriculado
     * @param _alumno {address} alumno address
     *
     */
    function estaMatriculado(address _alumno) private view returns (bool) {
        string memory _nombre = datosAlumno[_alumno].nombre;
        return bytes(_nombre).length != 0;
    }

    /**
     *
     * cerrar
     * @dev cierra la asignatura
     *
     */
    function cerrar() external soloCoordinador {
        cerrada = true;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // COORDINADOR
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * setCoordinador
     * @dev Set address to coordinador
     * @param _coordinador {address} Coordinador address
     *
     */
    function setCoordinador(
        address _coordinador
    ) external soloOwner soloAbierta {
        require(
            _coordinador != address(0),
            unicode"La direccion del coordinador parece que no es correcta"
        );
        coordinador = _coordinador;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // PROFESOR
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * addProfesor
     * @dev Create a new profesor
     * @param _profesor_address {address}       Dirección del profesor
     * @param _name             {string memory} Nombre del profesor
     *
     */
    function addProfesor(
        address _profesor_address,
        string memory _name
    ) external soloOwner soloAbierta {
        require(
            bytes(_name).length > 0,
            unicode"El nombre del profesor no puede estar vacío"
        );
        require(
            bytes(datosProfesor[_profesor_address]).length == 0,
            unicode"El profesor ya existe"
        );

        datosProfesor[_profesor_address] = _name;
        profesores.push(_profesor_address);
    }

    /**
     *
     * matriculasLength
     * @dev getter de tamaño de array de profesores
     *
     * @return (uint)
     *
     */
    function profesoresLength() public view returns (uint) {
        return profesores.length;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // MATRICULAS
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * automatricula
     * @dev El alumno se puede matricular
     *
     * @param _nombre   {string memory} Nombre de alumno
     * @param _dni      {string memory} Dni de alumno
     * @param _email    {string memory} Email de alumno
     *
     */
    function automatricula(
        string memory _nombre,
        string memory _dni,
        string memory _email
    ) public soloNoMatriculados soloAbierta {
        require(bytes(_nombre).length != 0, "El nombre no puede ser vacio");
        require(bytes(_dni).length != 0, "El DNI no puede ser vacio");
        if (doesAlumnoDNIExists(_dni)) {
            revert DNI_Already_Exists(_dni);
        }

        DatosAlumno memory datos = DatosAlumno(_nombre, _email, _dni);
        datosAlumno[msg.sender] = datos;
        matriculas.push(msg.sender);
    }

    /**
     *
     * matricular
     * @dev El propietario puede matricular a alumnos
     *
     * @param _address  {address}       Dirección de alumno
     * @param _nombre   {string memory} Nombre de alumno
     * @param _dni      {string memory} Dni de alumno
     * @param _email    {string memory} Email de alumno
     *
     */
    function matricular(
        address _address,
        string memory _nombre,
        string memory _dni,
        string memory _email
    ) public soloOwner soloAbierta {
        require(bytes(_nombre).length != 0, "El nombre no puede ser vacio");
        require(bytes(_dni).length != 0, "El DNI no puede ser vacio");
        require(!doesAlumnoDNIExists(_dni), "Ya hay alguien con ese DNI");

        DatosAlumno memory datos = DatosAlumno(_nombre, _email, _dni);
        datosAlumno[_address] = datos;
        matriculas.push(_address);
    }

    /**
     *
     * matriculasLength
     * @dev getter de tamaño de array de matrículas
     *
     * @return (uint)
     *
     */
    function matriculasLength() public view returns (uint) {
        return matriculas.length;
    }

    /**
     *
     * quienSoy
     * @dev retorna el nombre e email de una persona matriculada
     *
     * @return _nombre  {string memory}
     * @return _email   {string memory}
     *
     */
    function quienSoy()
        public
        view
        soloMatriculados
        returns (string memory _nombre, string memory _email)
    {
        DatosAlumno memory datos = datosAlumno[msg.sender];
        _nombre = datos.nombre;
        _email = datos.email;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // EVALUACIÓN
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * creaEvaluacion
     * @dev crea una nueva evaluación para la asignatura
     *
     * @param _nombre       {string memory}
     * @param _fecha        {uint}
     * @param _porcentaje   {uint}
     * @param _nota_minima  {uint}
     *
     * @return indice       {uint}
     *
     */
    function creaEvaluacion(
        string memory _nombre,
        uint _fecha,
        uint _porcentaje,
        uint _nota_minima
    ) public soloCoordinador soloAbierta returns (uint) {
        require(
            bytes(_nombre).length != 0,
            unicode"El nombre de la evaluacion no puede ser vacio"
        );
        require(
            _porcentaje < 100,
            unicode"No puedes tener un porcentaje tan alto"
        );

        evaluaciones.push(
            Evaluacion(_nombre, _fecha, _porcentaje, _nota_minima)
        );
        return evaluaciones.length - 1;
    }

    function evaluacionesLength() public view returns (uint) {
        return evaluaciones.length;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // CALIFICACIONES x EVALUACION
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * califica
     * @dev califica un alumno en una evaluación
     *
     * @param _alumno       {address}
     * @param _evaluacion   {uint}
     * @param _tipo         {TipoNota}
     * @param _calificacion {uint}
     *
     */
    function califica(
        address _alumno,
        uint _evaluacion,
        TipoNota _tipo,
        uint _calificacion
    ) public soloProfesor soloAbierta {
        require(
            estaMatriculado(_alumno),
            "Solo se pueden calificar a un alumno matriculado."
        );
        require(
            _evaluacion < evaluaciones.length,
            "No se puede calificar una evaluacion que no existe."
        );
        require(
            _calificacion <= 1000,
            "No se puede calificar con una nota superior a la maxima permitida."
        );

        Nota memory nota = Nota(_tipo, _calificacion);
        calificaciones[_alumno][_evaluacion] = nota;
    }

    /**
     *
     * miNota
     * @dev se consulta una calificación en una evaluación por alumno
     *
     * @param _evaluacion   {uint}
     *
     * @return _tipo         {TipoNota}
     * @return _calificacion {uint}
     *
     */
    function miNota(
        uint _evaluacion
    )
        public
        view
        soloMatriculados
        returns (TipoNota _tipo, uint _calificacion)
    {
        require(
            _evaluacion < evaluaciones.length,
            "El indice de la evaluacion no existe."
        );

        Nota memory nota = calificaciones[msg.sender][_evaluacion];
        _tipo = nota.tipo;
        _calificacion = nota.calificacion;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // NOTAS FINALES
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    /**
     *
     * notaFinal
     * @dev se calcula la nota final de un alumno sabiendo su dirección
     *
     * @param _address   {address}
     *
     * @return tipo_nota         {TipoNota}
     * @return nota_final {uint}
     *
     */
    function notaFinal(
        address _address
    )
        public
        view
        soloCoordinador
        returns (TipoNota tipo_nota, uint nota_final)
    {
        (tipo_nota, nota_final) = computeNotaFinal(_address);
    }

    /**
     *
     * miNotaFinal
     * @dev se calcula la nota final de un alumno sabiendo su dirección
     *
     *
     * @return tipo_nota         {TipoNota}
     * @return nota_final {uint}
     *
     */
    function miNotaFinal()
        public
        view
        soloMatriculados
        returns (TipoNota tipo_nota, uint nota_final)
    {
        (tipo_nota, nota_final) = computeNotaFinal(msg.sender);
    }

    /**
     *
     * miNotaFinal
     * @dev se calcula la nota final de un alumno sabiendo su dirección
     *
     * @param _address   {address}
     *
     * @return tipo_nota         {TipoNota}
     * @return nota_final {uint}
     *
     */
    function computeNotaFinal(
        address _address
    ) private view returns (TipoNota tipo_nota, uint nota_final) {
        bool isAllNP = true;
        bool isAnyNP = false;
        uint notasPondSum = 0;
        uint totalPond = 0;
        for (uint i = 0; i < evaluacionesLength(); i++) {
            // empty case
            if (calificaciones[_address][i].tipo == TipoNota.Empty) {
                tipo_nota = TipoNota.Empty;
                nota_final = 0;
                break;
            }
            if (calificaciones[_address][i].tipo != TipoNota.NP) {
                isAllNP = false;
            }
            if (calificaciones[_address][i].tipo == TipoNota.NP) {
                isAnyNP = true;
            }
            totalPond += evaluaciones[i].porcentaje;
            notasPondSum +=
                calificaciones[_address][i].calificacion *
                evaluaciones[i].porcentaje;
        }

        // case np
        if (isAllNP) {
            tipo_nota = TipoNota.NP;
            nota_final = 0;
        } else {
            // case normal
            tipo_nota = TipoNota.Normal;
            nota_final = notasPondSum / totalPond;

            // case any np
            if (isAnyNP && nota_final > 499) {
                nota_final = 499;
            }
        }
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // MODIFIERS
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    modifier soloOwner() {
        require(msg.sender == owner, "Solo permitido al propietario");
        _;
    }

    modifier soloCoordinador() {
        require(msg.sender == coordinador, "Solo permitido al coordinador");
        _;
    }

    modifier soloProfesor() {
        require(msg.sender == profesor, "Solo permitido al profesor");
        _;
    }

    modifier soloMatriculados() {
        require(
            estaMatriculado(msg.sender),
            "Solo permitido a alumnos matriculados"
        );
        _;
    }

    modifier soloNoMatriculados() {
        require(
            !estaMatriculado(msg.sender),
            "Solo permitido a alumnos no matriculados"
        );
        _;
    }

    modifier soloAbierta() {
        require(!cerrada, unicode"Las asignatura está cerrada");
        _;
    }

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // CUSTOM ERRORS
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    error DNI_Already_Exists(string dni);

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // RECEIVE Y FALLBACK
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    receive() external payable {
        revert("No se permite la recepcion de dinero.");
    }
}
