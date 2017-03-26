class Ab < Formula
  desc "Apache HTTP server benchmarking tool"
  homepage "https://httpd.apache.org/docs/trunk/programs/ab.html"
  url "https://archive.apache.org/dist/httpd/httpd-2.4.25.tar.bz2"
  sha256 "f87ec2df1c9fee3e6bfde3c8b855a3ddb7ca1ab20ca877bd0e2b6bf3f05c80b2"

  bottle do
    cellar :any
    sha256 "e2ace1d25594d170f2f65fb0fd672fe1c83eda535cc1e8bd03d4e97f2205cb77" => :sierra
    sha256 "dc21fd2be82b6b9f1cd1c08234f1379234fccc643dde354d0c6806730768bda7" => :el_capitan
    sha256 "eec4c9e6eba01ab9f7221ecd165703ea31cd43bc7272d162fdea7e783c1974f3" => :yosemite
  end

  keg_only :provided_by_osx

  depends_on "apr-util"
  depends_on "libtool" => :build

  conflicts_with "httpd22", "httpd24", :because => "both install `ab`"

  # Disable requirement for PCRE, because "ab" does not use it
  patch :DATA

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV["LTFLAGS"] = "--tag CC"
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-apr=#{Formula["apr"].opt_prefix}",
                          "--with-apr-util=#{Formula["apr-util"].opt_prefix}"

    cd "support" do
      system "make", "ab"
      bin.install "ab"
    end
    man1.install "docs/man/ab.1"
  end

  test do
    system "#{bin}/ab", "-k", "-n", "10", "-c", "10", "http://www.apple.com/"
  end
end

__END__
diff --git a/configure b/configure
index 90ae8be..243e9cf 100755
--- a/configure
+++ b/configure
@@ -6156,8 +6156,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi
 
-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi
 
   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
