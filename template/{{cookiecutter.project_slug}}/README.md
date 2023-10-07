{%- if cookiecutter.remix.lower() == "yes" -%}
{%- set remix = True %}
{%- else -%}
{%- set remix = False %}
{%- endif -%}
{%- if cookiecutter.original_model_license == "CC-BY-4.0" -%}
{%- set license_title = "Creative Commons (4.0 International License) Attribution" -%}
{%- set license_url = "http://creativecommons.org/licenses/by/4.0/" -%}
{%- elif cookiecutter.original_model_license == "CC-BY-SA-4.0" -%}
{%- set license_title = "Creative Commons (4.0 International License) Attribution-ShareAlike" -%}
{%- set license_url = "http://creativecommons.org/licenses/by-sa/4.0/" -%}
{%- elif cookiecutter.original_model_license == "CC-BY-NC-4.0" -%}
{%- set license_title = "Creative Commons (4.0 International License) Attribution-NonCommercial" -%}
{%- set license_url = "http://creativecommons.org/licenses/by-nc/4.0/" -%}
{%- elif cookiecutter.original_model_license == "CC-BY-NC-SA-4.0" -%}
{%- set license_title = "Creative Commons (4.0 International License) Attribution-NonCommercial-ShareAlike" -%}
{%- set license_url = "http://creativecommons.org/licenses/by-nc-sa/4.0/" -%}
{%- endif -%}
# {{ cookiecutter.title }}{% if remix %} (remix){% endif %}

[![{{ cookiecutter.original_model_license }} license][license-badge]][license]

{{ cookiecutter.description }}
{% if remix %}
## Attribution and License

This is a remix of
[**{{ cookiecutter.original_model_title|default("this model") }}** by **{{ cookiecutter.original_model_author }}**][original-model-url].

Both the original model and this remix are licensed under
[{{ license_title }}][license].
{% else %}
## License

This model is licensed under [{{ license_title}}][license].
{% endif %}
{% if remix -%}
[original-model-url]: {{ cookiecutter.original_model_url }}
{%- endif %}
[license]: {{ license_url }}
[license-badge]: /utils/license-badge-{{ cookiecutter.original_model_license.lower() }}.svg
