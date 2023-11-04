// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract AsignaturaFull {
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
    enum TipoNota {
        Empty,
        NP,
        Normal
    }
    struct Nota {
        TipoNota tipo;
        uint calificacion;
    }

    string public version = "2022 Lite";
    string public nombre;
    string public curso;
    bool public cerrada;

    address public immutable owner;
    address public profesor;
    address public coordinador;
    address[] public profesores;
    address[] public matriculas;

    Evaluacion[] public evaluaciones;
    mapping(address => DatosAlumno) public datosAlumno;
    mapping(address => string) public datosProfesor;
    mapping(address => mapping(uint => Nota)) public calificaciones;

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

    function setCoordinador(address coordinador_) external {
        require(
            coordinador_ != address(0),
            "tiene que haber un address correcto"
        );
        coordinador = coordinador_;
    }

    function automatricula(
        string memory _nombre,
        string memory _dni,
        string memory _email
    ) public soloNoMatriculados estaCerrada {
        require(bytes(_nombre).length != 0, "El nombre no puede ser vacio");
        require(bytes(_dni).length != 0, "El DNI no puede ser vacio");
        require(doesAlumnoDNIExists(_dni), "Ya hay alguien con ese DNI");

        DatosAlumno memory datos = DatosAlumno(_nombre, _email, _dni);
        datosAlumno[msg.sender] = datos;
        matriculas.push(msg.sender);
    }

    function doesAlumnoDNIExists(
        string memory _dni
    ) private view returns (bool) {
        bool boolOut = false;
        for (uint i = 0; i < matriculas.length; i++) {
            if (compareStrings(datosAlumno[matriculas[i]].dni, _dni)) {
                boolOut = true;
                break;
            }
        }
        return boolOut;
    }

    function matricular(
        address _address,
        string memory _nombre,
        string memory _dni,
        string memory _email
    ) public {
        require(bytes(_nombre).length != 0, "El nombre no puede ser vacio");
        require(bytes(_dni).length != 0, "El DNI no puede ser vacio");
        require(doesAlumnoDNIExists(_dni), "Ya hay alguien con ese DNI");

        DatosAlumno memory datos = DatosAlumno(_nombre, _email, _dni);
        datosAlumno[_address] = datos;
        matriculas.push(_address);
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return (keccak256(abi.encodePacked(a)) ==
            keccak256(abi.encodePacked(b)));
    }

    function matriculasLength() public view returns (uint) {
        return matriculas.length;
    }

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

    function profesoresLength() public view returns (uint) {
        return profesores.length;
    }

    function creaEvaluacion(
        string memory _nombre,
        uint _fecha,
        uint _porcentaje,
        uint _nota_minima
    ) public soloProfesor returns (uint) {
        require(
            bytes(_nombre).length != 0,
            "El nombre de la evaluacion no puede ser vacio"
        );
        require(
            _porcentaje > 100,
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

    function califica(
        address alumno,
        uint evaluacion,
        TipoNota tipo,
        uint calificacion
    ) public soloProfesor estaCerrada {
        require(
            estaMatriculado(alumno),
            "Solo se pueden calificar a un alumno matriculado."
        );
        require(
            evaluacion < evaluaciones.length,
            "No se puede calificar una evaluacion que no existe."
        );
        require(
            calificacion <= 1000,
            "No se puede calificar con una nota superior a la maxima permitida."
        );

        Nota memory nota = Nota(tipo, calificacion);
        calificaciones[alumno][evaluacion] = nota;
    }

    function miNota(
        uint evaluacion
    ) public view soloMatriculados returns (TipoNota tipo, uint calificacion) {
        require(
            evaluacion < evaluaciones.length,
            "El indice de la evaluacion no existe."
        );

        Nota memory nota = calificaciones[msg.sender][evaluacion];
        tipo = nota.tipo;
        calificacion = nota.calificacion;
    }

    function notaFinal(
        address _address
    ) public view returns (TipoNota tipo_nota, uint nota_final) {
        bool isAllNP = true;
        bool isAnyNP = false;
        uint notasSum = 0;
        for (uint i = 0; i < evaluacionesLength(); i++) {
            // empty case
            if (calificaciones[_address][i].tipo == TipoNota.Empty) {
                tipo_nota = TipoNota.Empty;
                nota_final = 0;
                break;
            }
            if (calificaciones[_address][i].tipo != TipoNota.NP) {
                isAllNP = false;
                break;
            }
            if (calificaciones[_address][i].tipo == TipoNota.NP) {
                isAnyNP = true;
            }

            notasSum += calificaciones[_address][i].calificacion;
        }

        // case np
        if (isAllNP) {
            tipo_nota = TipoNota.NP;
            nota_final = 0;
        } else {
            // case normal
            tipo_nota = TipoNota.Normal;
            nota_final = notasSum / evaluacionesLength();

            // case any np
            if (isAnyNP && nota_final > 499) {
                nota_final = 499;
            }
        }
    }

    function miNotaFinal()
        public
        view
        returns (TipoNota tipo_nota, uint nota_final)
    {
        (tipo_nota, nota_final) = notaFinal(msg.sender);
    }

    function estaMatriculado(address alumno) private view returns (bool) {
        string memory _nombre = datosAlumno[alumno].nombre;

        return bytes(_nombre).length != 0;
    }

    function cerrar() external {
        cerrada = true;
    }

    function addProfesor(
        address profesor_address_,
        string memory name_
    ) external {
        require(
            bytes(name_).length > 0,
            unicode"El nombre del profesor no puede estar vacío"
        );
        require(
            bytes(datosProfesor[profesor_address_]).length > 0,
            unicode"El profesor ya existe"
        );

        datosProfesor[profesor_address_] = name_;
        profesores.push(profesor_address_);
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

    modifier estaCerrada() {
        require(
            !cerrada,
            unicode"La asignatura ya está cerrada, no se puede modificar"
        );
        _;
    }

    receive() external payable {
        revert("No se permite la recepcion de dinero.");
    }
}
