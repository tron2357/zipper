#!/bin/bash
# vim: sts=2 ts=2 sw=2 et ai

# natsort: sort -V

# マルチバイト文字の有無をチェック
# $ret: マルチバイトファイル名のファイル数
check_multibyte() {
  dir="$1"
  ret=0

  cd "$dir"
  while read file
  do
    byte=`echo -n $file | wc -c`
    count=${#file}
  
    [ $byte -eq $count ] || ret=`expr $ret + 1`
  
  done < <(find . -type f -print0 | xargs --no-run-if-empty -0 -n1 basename | sort)
  cd ..

  return $ret
}

# 重複ファイル名の有無をチェック
# $ret: 重複ファイル数
check_duplicate() {
  dir="$1"
  ret=0

  cd "$dir"
  all=` find . -type f -print0 | xargs --no-run-if-empty -0 -n1 basename |               wc -l` 
  uniq=`find . -type f -print0 | xargs --no-run-if-empty -0 -n1 basename | sort | uniq | wc -l`

  [ $all -eq $uniq ] || ret=`expr $all - $uniq`
  cd ..

  return $ret
}

# 圧縮の実行
make_zip() {
  dir="$1"
  ret=0

  echo "compress: $dir"

  temp="__temp"

  cd "$dir"
  mkdir -p $temp

  # $tempを除外しないとタイミングにより一覧に入ることがある
  find . -type d -name $temp -prune -o -type f -exec mv "{}" $temp/ \;

    cd $temp

    # 1ファイルごとaddすると遅いためリストで渡す
    # -0: 無圧縮
    find . -type f | sort -V | zip -q -0 "${dir}.zip" -@
    mv "${dir}.zip" ../../

    cd ..
  cd ..

  return $ret
}

# 最初に全てのファイルをチェックする
errs=0
while read dir
do
#  echo ${dir}

  check_multibyte "$dir"
  multi=$?

  check_duplicate "$dir"
  dup=$?

#  echo "$dir: multi=$multi, dup=$dup"

  if [ $multi -ne 0 ]; then
    errs=`expr $errs + 1`
    echo "ERROR: multibyte $dir" 
  fi

  if [ $dup -ne 0 ]; then
    errs=`expr $errs + 1`
    echo "ERROR: duplicate $dir" 
  fi

done < <(find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs --no-run-if-empty -0 -n1 basename | sort)


echo -e "errs=$errs\n\n---"

# ファイルに不備があるときは圧縮せず終了
[ $errs -eq 0 ] || exit $errs


# 実際に圧縮する
while read dir
do
#  echo ${dir}

  make_zip "$dir"

done < <(find . -mindepth 1 -maxdepth 1 -type d -print0 | xargs --no-run-if-empty -0 -n1 basename | sort)
