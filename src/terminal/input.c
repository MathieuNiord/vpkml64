#include <caml/alloc.h>
#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/callback.h>

#include <windows.h>
#include <conio.h>

int get_char_input () {
    int ch = _getch();

    if (ch == 0 || ch == 224) { // Arrow keys
        ch = _getch();
        switch(ch) {
            case 72: return Int_val(caml_callback(*caml_named_value("Up"), Val_unit));
            case 80: return Int_val(caml_callback(*caml_named_value("Down"), Val_unit));
            case 75: return Int_val(caml_callback(*caml_named_value("Left"), Val_unit));
            case 77: return Int_val(caml_callback(*caml_named_value("Right"), Val_unit));
        }
    }

    else if (ch == 27 || ch == 'q')
        return Int_val(caml_callback(*caml_named_value("Exit"), Val_unit));

    else if (ch == 13)
        return Int_val(caml_callback(*caml_named_value("Enter"), Val_unit));

    else return Int_val(caml_callback(*caml_named_value("None"), Val_unit));
}

CAMLprim value ocaml_input_get_interaction(value unit)
{
    CAMLparam1(unit);
    CAMLreturn(Val_int(get_char_input()));
}