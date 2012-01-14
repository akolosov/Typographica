# -*- encoding: utf-8 -*-
#
# Typographica v0.1
#
# Класс для типографической коррекции русского текста в HTML согласно правилам русского языка. Полная поддержка UTF-8.
#
# (C)opyLeft & (C)odeRight Alexey Kolosov aka mr.huNTer <alexey.kolosov@gmail.com>
#
# "Typographica" released without warranty under the terms of the Artistic License 2.0
# http://www.opensource.org/licenses/artistic-license-2.0
#

$KCODE = 'u' if RUBY_VERSION < "1.9"

module Typographica
  extend self

  # strToCorrect - строка для корректировки
  def typography(strToCorrect = "")

    if strToCorrect.empty?
      out = self
    else
      out = strToCorrect
    end

    symbols = { "¤" => "&#164;",
                "°" => "&deg;",
                "%" => "&#37;",
                "£" => "&#163;",
                "₤" => "&#8356;",
                "€" => "&euro;",
                "¥" => "&yen;"
              }

    # маски и паттерны для преобразования в формате { маска => паттерн, маска => паттерн, маска => паттерн, ... }
    masks = {
              # амперсанд
              %r[([a-zёа-я]+)\s*\&\s*([a-zёа-я]+)]sui => "<nobr>\\1&nbsp;&amp;&nbsp;\\2</nobr>", #
              %r[([a-zёа-я]+)\s+\&\s+]sui => "\\1&nbsp;&amp; ", #

              # тире, дефисы, апострофы
              %r[(^|>|\s)([a-zёа-я]+([\-\'\/][a-zёа-я]+)+)]sui => "\\1<nobr>\\2</nobr>", #
              %r[([a-zёа-я]+)\s+\-\s+]sui => "\\1&nbsp;&mdash; ", #
              %r[(^|>|\s)\-\s+]sui => "\\1&mdash;&nbsp;", #

              # знаки препинания
              %r[(\s*)([,\?\!\.]*)]sui => "\\2\\1", #
              %r[(.*?)([\,\;])([^\-\&]+?)(.*?)]sui => "\\1\\2 \\3\\4", #
              %r[([^\(ЁА-ЯA-Z][\.\?\!])([ЁА-ЯA-Z])]su => "\\1 \\2", #
              %r[(\s*)([\.\?\!]*)(\s*[ЁА-ЯA-Z])]su => "\\2\\1\\3", #
              %r[([a-zёа-я]+)\.{3,}]sui => "<nobr>\\1&#133;</nobr>", #
              %r[\.{3,}]sui => "&#133;", #

              # кавычки
              %r[(^|\s|>|\)|\()\"(.*?)\"]sui => "\\1&laquo;\\2&raquo;", #
              %r[(^|\s|>|\)|\()“(.*?)”]sui => "\\1&laquo;\\2&raquo;", #
              %r[(^|\s|>|\)|\()„(.*?)”]sui => "\\1&laquo;\\2&raquo;", #
              %r[„]sui => "&#132;", #
              %r[“]sui => "&#147;", #
              %r[”]sui => "&#148;", #

              # спецсимволы
              %r[\(c\)]i => "&#169;", #
              %r[\(r\)]i => "&#174;", #
              %r[\(p\)]i => "&#8471;", #
              %r[\(tm\)]i => "&#153;", #
              %r[\(sm\)]i => "&#8480;", #

              # номер
              %r[(^|\s)no\.?\s?(\d+)]sui => "\\1\u2116\\2", # no. 123 -> №123

              # даты, телефонные номера, проценты
              %r[([0-9]{4})([\-\/\.])([0-9]{2})[\-\/\.]([0-9]{2})]su =>
                "<nobr>\\4\\2\\3\\2\\1</nobr>", # 1990-12-31 -> 31-12-1990, 1990/12/31 -> 31/12/1990, 1990.12.31 -> 31.12.1990
              %r[(\([0-9\+\-]+\))\s?([0-9]{3})\-?([0-9]{2})\-?([0-9]{2})]su =>
                "<nobr>\\1&nbsp;\\2&ndash;\\3&ndash;\\4</nobr>", # (904)4749303 -> (904) 474-93-03
              %r[(\([0-9\+\-]+\))\s?([0-9]{2})\-?([0-9]{2})\-?([0-9]{2})]su =>
                "<nobr>\\1&nbsp;\\2&ndash;\\3&ndash;\\4</nobr>", # (9044)749303 -> (9044) 74-93-03
              %r[(\([0-9\+\-]+\))\s?([0-9]{1})\-?([0-9]{2})\-?([0-9]{2})]su =>
                "<nobr>\\1&nbsp;\\2&ndash;\\3&ndash;\\4</nobr>", # (90447)49303 -> (90447) 4-93-03
              %r[(\-?[0-9]{1,})\s*([\%\°\£\₤\€])]su => "<nobr>\\1\\2</nobr>", # 80 % - 80%, 80 ° - 80°
              %r[(\-?[0-9]{1,})\s*([\$\¥])]su => "<nobr>\\2\\1</nobr>", # 80 $ - $80, 80 ¥ - ¥80

              # наводим красоту
              %r[\&nbsp\;\s+]sui => "&nbsp;", #
              %r[([\,\.\;\!\?])\ {2,}]sui => "\\1 ", #
              %r[(\&lt)\s+?]sui => "\\1", #
              %r[(\&gt)\s+?]sui => "\\1", #
              %r[(\"|\&quot)\s+(\"|\&quot)]sui => "", #

              # "мягкие" переносы для русского текста
              %r[([ёа-я][ьъй])([ёа-я]{2})]sui => "\\1&shy;\\2",
              %r[([ёа-я][аеёиоуыэюя])([аеёиоуыэюя][ёа-я])]sui => "\\1&shy;\\2",
              %r[([аеёиоуыэюя][бвгджзклмнпрстфхцчшщ])([бвгджзклмнпрстфхцчшщ][аеёиоуыэюя])]sui => "\\1&shy;\\2",
              %r[([бвгджзклмнпрстфхцчшщ][аеёиоуыэюя])([бвгджзклмнпрстфхцчшщ][аеёиоуыэюя])]sui => "\\1&shy;\\2",
              %r[([аеёиоуыэюя][бвгджзклмнпрстфхцчшщ])([бвгджзклмнпрстфхцчшщ][бвгджзклмнпрстфхцчшщ][аеёиоуыэюя])]sui => "\\1&shy;\\2",
              %r[([аеёиоуыэюя][бвгджзклмнпрстфхцчшщ][бвгджзклмнпрстфхцчшщ])([бвгджзклмнпрстфхцчшщ][бвгджзклмнпрстфхцчшщ][аеёиоуыэюя])]sui => "\\1&shy;\\2"
            }

    # начали приседания ...
    masks.each do |key, value|
      out.gsub!(key, value)
    end
    # ... продолжаем, не останавливаемся ...
    symbols.each do |key, value|
      out.gsub!(key, value)
    end
    # ... и закончили упражнение

    return out
  end

  def typography!()
    typography(self)
  end

end
